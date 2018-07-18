import XCTest
import SQLite3
import SQLite

class SQLiteDatabaseTests: XCTestCase {
    var directory: String!
    var path: String!
    var database: SQLite.Database!
    
    override func setUp() {
        super.setUp()
        directory = temporaryDirectory()
        path = (directory as NSString).appendingPathComponent("test.db")
        createDirectory(at: directory)
        database = try! SQLite.Database(path: path)
    }
    
    override func tearDown() {
        super.tearDown()
        database.close()
        removeDirectory(at: directory)
    }

    func testDatabaseIsCreated() {
        XCTAssertNotNil(database)
        XCTAssertTrue(FileManager().fileExists(atPath: path))
    }

    func testUserVersion() {
        XCTAssertEqual(0, database.userVersion)

        database.userVersion = 123
        XCTAssertEqual(123, database.userVersion)
    }

    func testCreateTable() {
        XCTAssertNoThrow(try database.execute(raw: _createTableWithBlob))
        let tableNames = try! _tableNames(in: database)
        XCTAssertEqual("test", tableNames[0])
    }

    func testInsertAndFetchBlob() {
        let one: SQLiteArguments = ["id": .integer(123), "data": .data(_textData)]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithBlob))
        XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: one))

        var fetched: Array<SQLiteRow> = []
        XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .integer(123)]))
        XCTAssertEqual(1, fetched.count)
        XCTAssertEqual(one, fetched[0])
    }

    func testInsertAndFetchFloatStringAndData() {
        let one: SQLiteArguments =
            ["id": .integer(1), "float": .double(1.23), "string": .text("123"), "data": .data(_textData)]
        let two: SQLiteArguments =
            ["id": .integer(2), "float": .double(4.56), "string": .text("456"), "data": .data(_textData)]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithFloatStringData))
        XCTAssertNoThrow(try database.write(_insertIDFloatStringAndData, arguments: one))
        XCTAssertNoThrow(try database.write(_insertIDFloatStringAndData, arguments: two))

        for (id, target) in [1: one, 2: two] {
            var fetched: Array<SQLiteRow> = []
            XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .integer(Int64(id))]))
            XCTAssertEqual(1, fetched.count)
            XCTAssertEqual(target, fetched[0])
        }
    }

    func testInsertAndFetchNullableText() {
        let one: SQLiteArguments = ["id": .text("not null"), "string": .text("so not null")]
        let two: SQLiteArguments = ["id": .text("null"), "string": .null]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithIDAsStringAndNullableString))
        XCTAssertNoThrow(try database.write(_insertIDAndString, arguments: one))
        XCTAssertNoThrow(try database.write(_insertIDAndString, arguments: two))

        for (id, target) in ["not null": one, "null": two] {
            var fetched: Array<SQLiteRow> = []
            XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .text(id)]))
            XCTAssertEqual(1, fetched.count)
            XCTAssertEqual(target, fetched[0])
        }
    }

    func testInsertTextIntoTypesafeDataColumnFails() {
        let one: SQLiteArguments = ["id": .integer(123), "data": .data(_textData)]
        let two: SQLiteArguments = ["id": .integer(456), "data": .text(_text)]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithTypesafeBlob))
        XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: one))
        XCTAssertThrowsError(try database.write(_insertIDAndData, arguments: two)) { (error) in
            if case SQLite.Error.onStep(let code, _) = error {
                XCTAssertEqual(SQLITE_CONSTRAINT, code)
            } else {
                XCTFail("'\(error)' should be 'SQLite.Error.onStep'")
            }
        }
    }

    func testInsertNilIntoNonNullDataColumnFails() {
        let one: SQLiteArguments = ["id": .integer(123), "data": .null]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithBlob))
        XCTAssertThrowsError(try database.write(_insertIDAndData, arguments: one)) { (error) in
            if case SQLite.Error.onStep(let code, _) = error {
                XCTAssertEqual(SQLITE_CONSTRAINT, code)
            } else {
                XCTFail("'\(error)' should be 'SQLite.Error.onStep'")
            }
        }
    }

    func testInsertOrReplaceWithSameIDReplacesRows() {
        let one: SQLiteArguments = ["id": .text("1"), "string": .text("one")]
        let two: SQLiteArguments = ["id": .text("2"), "string": .text("two")]

        let oneUpdated: SQLiteArguments = ["id": .text("1"), "string": .text("updated")]
        let twoUpdated: SQLiteArguments = ["id": .text("2"), "string": .null]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithIDAsStringAndNullableString))
        XCTAssertNoThrow(try database.write(_insertOrReplaceIDAndString, arguments: one))
        XCTAssertNoThrow(try database.write(_insertOrReplaceIDAndString, arguments: two))

        XCTAssertNoThrow(try database.write(_insertOrReplaceIDAndString, arguments: oneUpdated))
        XCTAssertNoThrow(try database.write(_insertOrReplaceIDAndString, arguments: twoUpdated))

        for (id, target) in ["1": oneUpdated, "2": twoUpdated] {
            var fetched: Array<SQLiteRow> = []
            XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .text(id)]))
            XCTAssertEqual(1, fetched.count)
            XCTAssertEqual(target, fetched[0])
        }
    }

    func testInsertFloatStringAndDataInTransaction() {
        let one: SQLiteArguments =
            ["id": .integer(1), "float": .double(1.23), "string": .text("123"), "data": .data(_textData)]
        let two: SQLiteArguments =
            ["id": .integer(2), "float": .double(4.56), "string": .text("456"), "data": .data(_textData)]
        let three: SQLiteArguments =
            ["id": .integer(3), "float": .double(7.89), "string": .text("789"), "data": .data(_textData)]
        let four: SQLiteArguments =
            ["id": .integer(4), "float": .double(0.12), "string": .text("012"), "data": .data(_textData)]
        let five: SQLiteArguments =
            ["id": .integer(5), "float": .double(3.45), "string": .text("345"), "data": .data(_textData)]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithFloatStringData))

        let block = {
            for row in [one, two, three, four, five] {
                XCTAssertNoThrow(try self.database.write(self._insertIDFloatStringAndData, arguments: row))
            }
        }

        var transactionResult: Bool = false
        XCTAssertNoThrow(transactionResult = try database.inTransaction(block))
        XCTAssertTrue(transactionResult)

        for (id, target) in [1: one, 2: two, 3: three, 4: four, 5: five] {
            var fetched: Array<SQLiteRow> = []
            XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .integer(Int64(id))]))
            XCTAssertEqual(1, fetched.count)
            XCTAssertEqual(target, fetched[0])
        }
    }

    func testInvalidInsertOfBlobInTransactionRollsBack() {
        let one: SQLiteArguments = ["id": .integer(1), "data": .data(_textData)]
        let two: SQLiteArguments = ["id": .integer(2)]

        XCTAssertNoThrow(try database.execute(raw: _createTableWithBlob))
        XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: one))

        var transactionResult: Bool = true
        let block = { try self.database.write(self._insertIDAndData, arguments: two) }
        XCTAssertNoThrow(transactionResult = try database.inTransaction(block))
        XCTAssertFalse(transactionResult)

        var fetched: Array<SQLiteRow> = []
        XCTAssertNoThrow(fetched = try database.read(_selectWhereID, arguments: ["id": .integer(1)]))
        XCTAssertEqual(1, fetched.count)
        XCTAssertEqual(one, fetched[0])
    }

    func testHasOpenTransactions() {
        func arguments(with id: Int) -> SQLiteArguments {
            return ["id": .integer(Int64(id)), "data": .data(_textData)]
        }

        XCTAssertNoThrow(try database.execute(raw: _createTableWithBlob))

        let success1 = try! database.inTransaction {
            XCTAssertTrue(database.hasOpenTransactions)
            XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: arguments(with: 1)))
        }
        XCTAssertTrue(success1)
        XCTAssertFalse(database.hasOpenTransactions)

        let success2 = try! database.inTransaction {
            XCTAssertTrue(database.hasOpenTransactions)
            XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: arguments(with: 2)))
            let success3 = try! database.inTransaction {
                XCTAssertTrue(database.hasOpenTransactions)
                XCTAssertNoThrow(try database.write(_insertIDAndData, arguments: arguments(with: 3)))
            }
            XCTAssertTrue(success3)
            XCTAssertTrue(database.hasOpenTransactions)
        }
        XCTAssertTrue(success2)
        XCTAssertFalse(database.hasOpenTransactions)
    }
}

extension SQLiteDatabaseTests {
    fileprivate var _createTableWithBlob: String {
        return """
        CREATE TABLE test (
            id INTEGER PRIMARY KEY NOT NULL,
            data BLOB NOT NULL
        );
        """
    }

    fileprivate var _createTableWithTypesafeBlob: String {
        return """
        CREATE TABLE test (
            id INTEGER NOT NULL PRIMARY KEY,
            data BLOB CHECK(typeof(data) = 'blob')
        );
        """
    }

    fileprivate var _insertIDAndData: String {
        return "INSERT INTO test VALUES (:id, :data);"
    }

    fileprivate var _createTableForTestingUniqueColumns: String {
        return """
        CREATE TABLE test (
            id1 INTEGER PRIMARY KEY NOT NULL,
            uniqueText TEXT NOT NULL UNIQUE,
            uniqueIndexDouble DOUBLE NOT NULL,
            normalDouble DOUBLE NOT NULL
        );
        """
    }

    fileprivate var _createTableWithTwoPrimaryKeysForTestingUniqueColumns: String {
        return """
        CREATE TABLE test (
            id1 INTEGER,
            id2 INTEGER,
            uniqueText TEXT UNIQUE,
            uniqueIndexDouble DOUBLE,
            normalDouble DOUBLE,
            PRIMARY KEY(id1, id2)
        );
        """
    }

    fileprivate var _createUniqueIndexDoubleIndex: String {
        return "CREATE UNIQUE INDEX test_unique_index_double_index ON test (uniqueIndexDouble);"
    }

    fileprivate var _createTableWithFloatStringData: String {
        return """
        CREATE TABLE test (
            id INTEGER PRIMARY KEY NOT NULL,
            float DOUBLE NOT NULL,
            string TEXT NOT NULL,
            data BLOB NOT NULL
        );
        """
    }

    fileprivate var _insertIDFloatStringAndData: String {
        return "INSERT INTO test VALUES (:id, :float, :string, :data);"
    }

    fileprivate var _createTableWithIDAsStringAndNullableString: String {
        return """
        CREATE TABLE test (
            id TEXT PRIMARY KEY NOT NULL,
            string TEXT
        );
        """
    }

    fileprivate var _insertIDAndString: String {
        return "INSERT INTO test VALUES (:id, :string)"
    }

    fileprivate var _insertOrReplaceIDAndString: String {
        return "INSERT OR REPLACE INTO test VALUES (:id, :string)"
    }

    fileprivate var _selectWhereID: String {
        return "SELECT * FROM test WHERE id=:id;"
    }
}

extension SQLiteDatabaseTests {
    fileprivate var _text: String {
        return "This is a test string! 我们要试一下！👩‍👩‍👧‍👧👮🏿"
    }

    fileprivate var _textData: Data {
        return _text.data(using: .utf8)!
    }
}

extension SQLiteDatabaseTests {
    fileprivate func _tableNames(in database: SQLite.Database) throws -> Array<String> {
        let sql = "SELECT * FROM sqlite_master WHERE type='table';"
        let tablesResult = try database.execute(raw: sql)
        return tablesResult.compactMap { $0["tbl_name"]?.stringValue }
    }
}

extension SQLiteDatabaseTests {
    fileprivate func temporaryDirectory() -> String {
        return (NSTemporaryDirectory() as NSString).appendingPathComponent("\(arc4random())")
    }

    fileprivate func createDirectory(at path: String) {
        let fileManager = FileManager()

        do {
            try? fileManager.removeItem(atPath: path)
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        } catch let error {
            assertionFailure("Could not create directory at '\(path)': \(error)")
        }
    }

    fileprivate func removeDirectory(at path: String) {
        let fileManager = FileManager()

        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            assertionFailure("Could not delete directory at '\(path)': \(error)")
        }
    }
}