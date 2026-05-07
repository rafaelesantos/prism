import Foundation
import Testing

@testable import PrismServer

@Suite("PrismGraphQLParser Extended Tests")
struct PrismGraphQLParserExtendedTests {

    @Test("Parses subscription")
    func subscription() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("subscription { onMessage { text } }")
        let op = doc.firstOperation!
        #expect(op.operationType == .subscription)
    }

    @Test("Parses float argument")
    func floatArg() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(price: 19.99) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .float(let v) = field.arguments[0].value {
                #expect(v == 19.99)
            } else {
                #expect(Bool(false), "Expected float value")
            }
        }
    }

    @Test("Parses negative integer")
    func negativeInt() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(offset: -5) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .int(let v) = field.arguments[0].value {
                #expect(v == -5)
            }
        }
    }

    @Test("Parses enum value argument")
    func enumArg() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(status: ACTIVE) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .enum(let v) = field.arguments[0].value {
                #expect(v == "ACTIVE")
            } else {
                #expect(Bool(false), "Expected enum value")
            }
        }
    }

    @Test("Parses variable definition")
    func variableDefinition() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query GetUser($id: ID!) { user(id: $id) { name } }")
        let op = doc.firstOperation!
        #expect(op.variableDefinitions.count == 1)
        #expect(op.variableDefinitions[0].name == "id")
        #expect(op.variableDefinitions[0].type == "ID!")
    }

    @Test("Parses variable with default value")
    func variableWithDefault() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query($limit: Int = 10) { items(limit: $limit) }")
        let op = doc.firstOperation!
        #expect(op.variableDefinitions.count == 1)
        if case .int(let v) = op.variableDefinitions[0].defaultValue {
            #expect(v == 10)
        }
    }

    @Test("Parses list type variable definition")
    func listTypeVar() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query($ids: [ID!]!) { users(ids: $ids) { name } }")
        let op = doc.firstOperation!
        #expect(op.variableDefinitions[0].type == "[ID!]!")
    }

    @Test("Parses list value argument")
    func listArg() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(tags: [\"a\", \"b\"]) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .list(let items) = field.arguments[0].value {
                #expect(items.count == 2)
                if case .string(let s) = items[0] { #expect(s == "a") }
            } else {
                #expect(Bool(false), "Expected list value")
            }
        }
    }

    @Test("Parses object value argument")
    func objectArg() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ field(input: {name: \"Alice\", age: 30}) }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .object(let obj) = field.arguments[0].value {
                if case .string(let name) = obj["name"] { #expect(name == "Alice") }
                if case .int(let age) = obj["age"] { #expect(age == 30) }
            } else {
                #expect(Bool(false), "Expected object value")
            }
        }
    }

    @Test("Parses fragment spread")
    func fragmentSpread() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ user { ...UserFields } }")
        let op = doc.firstOperation!
        if case .field(let field) = op.selectionSet[0] {
            if case .fragmentSpread(let name) = field.selectionSet[0] {
                #expect(name == "UserFields")
            } else {
                #expect(Bool(false), "Expected fragment spread")
            }
        }
    }

    @Test("Parses escaped strings")
    func escapedStrings() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse(#"{ field(val: "hello\nworld\t\"quoted\"\\slash") }"#)
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .string(let s) = field.arguments[0].value {
                #expect(s.contains("\n"))
                #expect(s.contains("\t"))
                #expect(s.contains("\""))
                #expect(s.contains("\\"))
            }
        }
    }

    @Test("Parses multiple operations")
    func multipleOperations() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query A { hello } query B { world }")
        #expect(doc.operations.count == 2)
        #expect(doc.operations[0].name == "A")
        #expect(doc.operations[1].name == "B")
    }

    @Test("Parses comments")
    func comments() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("""
            # This is a comment
            {
                # Another comment
                hello
            }
            """)
        let op = doc.firstOperation!
        #expect(op.selectionSet.count == 1)
    }

    @Test("Parses deeply nested selections")
    func deeplyNested() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ a { b { c { d } } } }")
        if case .field(let a) = doc.firstOperation!.selectionSet[0] {
            #expect(a.name == "a")
            if case .field(let b) = a.selectionSet[0] {
                #expect(b.name == "b")
                if case .field(let c) = b.selectionSet[0] {
                    #expect(c.name == "c")
                }
            }
        }
    }

    @Test("Throws on empty document")
    func emptyDocument() {
        let parser = PrismGraphQLParser()
        #expect(throws: PrismGraphQLExecutionError.self) {
            try parser.parse("")
        }
    }

    @Test("Throws on unknown operation type")
    func unknownOpType() {
        let parser = PrismGraphQLParser()
        #expect(throws: PrismGraphQLExecutionError.self) {
            try parser.parse("foobar { hello }")
        }
    }

    @Test("Throws on unterminated string")
    func unterminatedString() {
        let parser = PrismGraphQLParser()
        #expect(throws: PrismGraphQLExecutionError.self) {
            try parser.parse("{ field(val: \"unterminated) }")
        }
    }

    @Test("Variable reference in argument")
    func variableReference() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query($id: ID) { user(id: $id) { name } }")
        if case .field(let field) = doc.firstOperation!.selectionSet[0] {
            if case .variable(let name) = field.arguments[0].value {
                #expect(name == "id")
            }
        }
    }

    @Test("Multiple fields in selection set")
    func multipleFields() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ name age email }")
        let op = doc.firstOperation!
        #expect(op.selectionSet.count == 3)
    }

    @Test("responseName returns alias when present")
    func responseNameAlias() {
        let field = PrismGraphQLFieldSelection(alias: "myName", name: "name", arguments: [], selectionSet: [])
        #expect(field.responseName == "myName")
    }

    @Test("responseName returns name when no alias")
    func responseNameNoAlias() {
        let field = PrismGraphQLFieldSelection(alias: nil, name: "name", arguments: [], selectionSet: [])
        #expect(field.responseName == "name")
    }
}
