import Foundation
import Testing

@testable import PrismServer

private struct SendableDict: @unchecked Sendable {
    let value: [String: Any]
    init(_ value: [String: Any]) { self.value = value }
}

private struct SendableArray: @unchecked Sendable {
    let value: [Any]
    init(_ value: [Any]) { self.value = value }
}

@Suite("PrismGraphQLResult Tests")
struct PrismGraphQLResultTests {

    @Test("Empty errors become nil")
    func emptyErrors() {
        let result = PrismGraphQLResult(data: ["key": "value"], errors: [])
        #expect(result.errors == nil)
    }

    @Test("Non-empty errors preserved")
    func nonEmptyErrors() {
        let result = PrismGraphQLResult(
            data: nil,
            errors: [PrismGraphQLError(message: "fail")]
        )
        #expect(result.errors?.count == 1)
    }

    @Test("toJSON with data only")
    func toJSONDataOnly() throws {
        let result = PrismGraphQLResult(data: ["count": 5], errors: nil)
        let json = try JSONSerialization.jsonObject(with: result.toJSON()) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["count"] as? Int == 5)
        #expect(json?["errors"] == nil)
    }

    @Test("toJSON with errors and path")
    func toJSONWithErrors() throws {
        let error = PrismGraphQLError(
            message: "not found",
            path: ["user", "name"],
            locations: [PrismGraphQLSourceLocation(line: 1, column: 3)]
        )
        let result = PrismGraphQLResult(data: nil, errors: [error])
        let json = try JSONSerialization.jsonObject(with: result.toJSON()) as? [String: Any]
        let errors = json?["errors"] as? [[String: Any]]
        #expect(errors?.count == 1)
        #expect(errors?[0]["message"] as? String == "not found")
        let path = errors?[0]["path"] as? [String]
        #expect(path == ["user", "name"])
        let locations = errors?[0]["locations"] as? [[String: Any]]
        #expect(locations?[0]["line"] as? Int == 1)
        #expect(locations?[0]["column"] as? Int == 3)
    }

    @Test("toJSON sanitizes nested dict and array values")
    func toJSONSanitize() throws {
        let inner: [String: Any] = ["nested": "val"]
        let data: [String: Any] = [
            "str": "text",
            "num": 42,
            "dbl": 3.14,
            "flag": true,
            "null": NSNull(),
            "arr": [1, "two"],
            "obj": inner,
        ]
        let result = PrismGraphQLResult(data: data, errors: nil)
        let jsonData = result.toJSON()
        let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        let d = json?["data"] as? [String: Any]
        #expect(d?["str"] as? String == "text")
        #expect(d?["num"] as? Int == 42)
    }

    @Test("toJSON sanitizes custom type as string description")
    func toJSONCustomType() throws {
        struct Custom: CustomStringConvertible {
            var description: String { "custom-value" }
        }
        let result = PrismGraphQLResult(data: ["val": Custom()], errors: nil)
        let json = try JSONSerialization.jsonObject(with: result.toJSON()) as? [String: Any]
        let data = json?["data"] as? [String: Any]
        #expect(data?["val"] as? String == "custom-value")
    }
}

@Suite("PrismGraphQLError Tests")
struct PrismGraphQLErrorTests {

    @Test("toDict with message only")
    func toDictMessageOnly() {
        let error = PrismGraphQLError(message: "boom")
        let dict = error.toDict()
        #expect(dict["message"] as? String == "boom")
        #expect(dict["path"] == nil)
        #expect(dict["locations"] == nil)
    }

    @Test("toDict with all fields")
    func toDictAllFields() {
        let error = PrismGraphQLError(
            message: "err",
            path: ["a"],
            locations: [PrismGraphQLSourceLocation(line: 2, column: 5)]
        )
        let dict = error.toDict()
        let path = dict["path"] as? [String]
        #expect(path == ["a"])
        let locs = dict["locations"] as? [[String: Any]]
        #expect(locs?.count == 1)
    }
}

@Suite("PrismGraphQLExecutor Extended Tests")
struct PrismGraphQLExecutorExtendedTests {

    private func makeSimpleSchema(
        queryFields: [PrismGraphQLField] = [],
        mutationFields: [PrismGraphQLField]? = nil,
        subscriptionFields: [PrismGraphQLField]? = nil,
        types: [PrismGraphQLObjectType] = []
    ) -> PrismGraphQLSchema {
        let query = PrismGraphQLObjectType(name: "Query", fields: queryFields)
        let mutation = mutationFields.map { PrismGraphQLObjectType(name: "Mutation", fields: $0) }
        let subscription = subscriptionFields.map { PrismGraphQLObjectType(name: "Subscription", fields: $0) }
        return PrismGraphQLSchema(query: query, mutation: mutation, subscription: subscription, types: types)
    }

    @Test("No operations returns error")
    func emptyDocument() async {
        let parser = PrismGraphQLParser()
        #expect(throws: PrismGraphQLExecutionError.self) {
            try parser.parse("")
        }
    }

    @Test("Operation not found by name")
    func operationNotFoundByName() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query Foo { hello }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema, operationName: "Bar")
        #expect(result.errors?.first?.message.contains("not found") == true)
    }

    @Test("Mutation execution")
    func mutationExecution() async throws {
        let schema = makeSimpleSchema(
            queryFields: [PrismGraphQLField(name: "dummy", type: .string, resolve: { _ in "x" })],
            mutationFields: [
                PrismGraphQLField(name: "createUser", type: .string, resolve: { _ in "created" })
            ]
        )
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("mutation { createUser }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.data?["createUser"] as? String == "created")
    }

    @Test("Mutation on schema without mutation type returns error")
    func noMutationType() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("mutation { doSomething }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.errors?.first?.message.contains("mutations") == true)
    }

    @Test("Subscription on schema without subscription type returns error")
    func noSubscriptionType() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("subscription { onEvent }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.errors?.first?.message.contains("subscriptions") == true)
    }

    @Test("Resolver error produces GraphQL error")
    func resolverError() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "fail", type: .string, resolve: { _ in
                throw PrismGraphQLExecutionError.fieldNotFound("fail")
            })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ fail }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.errors != nil)
        #expect(result.errors!.count >= 1)
    }

    @Test("__typename introspection returns type name")
    func typenameIntrospection() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __typename }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.data?["__typename"] as? String == "Query")
    }

    @Test("__schema introspection returns schema info")
    func schemaIntrospection() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __schema { queryType { name } } }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        let schemaData = result.data?["__schema"] as? [String: Any]
        let queryType = schemaData?["queryType"] as? [String: Any]
        #expect(queryType?["name"] as? String == "Query")
    }

    @Test("__schema with mutationType and subscriptionType")
    func schemaIntrospectionWithMutationAndSubscription() async throws {
        let schema = makeSimpleSchema(
            queryFields: [PrismGraphQLField(name: "q", type: .string, resolve: { _ in "q" })],
            mutationFields: [PrismGraphQLField(name: "m", type: .string, resolve: { _ in "m" })],
            subscriptionFields: [PrismGraphQLField(name: "s", type: .string, resolve: { _ in "s" })]
        )
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __schema { queryType { name } mutationType { name } subscriptionType { name } } }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        let schemaData = result.data?["__schema"] as? [String: Any]
        let mutationType = schemaData?["mutationType"] as? [String: Any]
        #expect(mutationType?["name"] as? String == "Mutation")
        let subscriptionType = schemaData?["subscriptionType"] as? [String: Any]
        #expect(subscriptionType?["name"] as? String == "Subscription")
    }

    @Test("__schema types lists registered types")
    func schemaIntrospectionTypes() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __schema { types { name } } }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        let schemaData = result.data?["__schema"] as? [String: Any]
        let types = schemaData?["types"] as? [[String: Any]]
        let names = types?.compactMap { $0["name"] as? String }
        #expect(names?.contains("Query") == true)
    }

    @Test("__type introspection returns type info")
    func typeIntrospection() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, description: "Greeting", resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __type(name: \"Query\") { name kind fields { name description type { name } } } }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        let typeData = result.data?["__type"] as? [String: Any]
        #expect(typeData?["name"] as? String == "Query")
        #expect(typeData?["kind"] as? String == "OBJECT")
        let fields = typeData?["fields"] as? [[String: Any]]
        #expect(fields?.first?["name"] as? String == "hello")
    }

    @Test("__type returns null for unknown type")
    func typeIntrospectionUnknown() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "hello", type: .string, resolve: { _ in "world" })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ __type(name: \"Unknown\") { name } }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.data?["__type"] is NSNull)
    }

    @Test("Introspection fields with deprecation and args")
    func introspectionFieldsDetail() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(
                name: "old",
                type: .string,
                args: [PrismGraphQLArgument(name: "id", type: .id, description: "The ID")],
                deprecationReason: "Use newField",
                resolve: { _ in "old" }
            )
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse(
            "{ __type(name: \"Query\") { fields { name isDeprecated deprecationReason args { name description type { name } } } } }"
        )
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        let typeData = result.data?["__type"] as? [String: Any]
        let fields = typeData?["fields"] as? [[String: Any]]
        let field = fields?.first
        #expect(field?["isDeprecated"] as? Bool == true)
        #expect(field?["deprecationReason"] as? String == "Use newField")
        let args = field?["args"] as? [[String: Any]]
        #expect(args?.first?["name"] as? String == "id")
    }

    @Test("Null resolver value becomes NSNull")
    func nullResolverValue() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "nothing", type: .string, resolve: { _ in nil })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ nothing }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema)
        #expect(result.data?["nothing"] is NSNull)
    }

    @Test("Variables are passed to resolver")
    func variablesPassedToResolver() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(
                name: "greet",
                type: .string,
                args: [PrismGraphQLArgument(name: "name", type: .string)],
                resolve: { info in
                    let name: String = info.arg("name") ?? "world"
                    return "Hello, \(name)!"
                }
            )
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query($n: String) { greet(name: $n) }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema, variables: ["n": "Bob"])
        #expect(result.data?["greet"] as? String == "Hello, Bob!")
    }

    @Test("Context is passed to resolver")
    func contextPassedToResolver() async throws {
        let schema = makeSimpleSchema(queryFields: [
            PrismGraphQLField(name: "whoami", type: .string, resolve: { info in
                info.context as? String
            })
        ])
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("{ whoami }")
        let executor = PrismGraphQLExecutor()
        let result = await executor.execute(document: doc, schema: schema, context: "admin")
        #expect(result.data?["whoami"] as? String == "admin")
    }
}

@Suite("PrismGraphQLSchemaBuilder Tests")
struct PrismGraphQLSchemaBuilderTests {

    @Test("Build schema with query and mutation")
    func buildWithMutation() {
        var builder = PrismGraphQLSchemaBuilder()
        builder.query("hello", type: .string) { _ in "world" }
        builder.mutation("create", type: .string) { _ in "done" }
        let schema = builder.build()
        #expect(schema.query.fields["hello"] != nil)
        #expect(schema.mutation?.fields["create"] != nil)
    }

    @Test("Build schema with custom types")
    func buildWithCustomTypes() {
        var builder = PrismGraphQLSchemaBuilder()
        builder.query("dummy", type: .string) { _ in "x" }
        let userType = PrismGraphQLObjectType(
            name: "User",
            fields: [PrismGraphQLField(name: "name", type: .string, resolve: { _ in "test" })]
        )
        builder.addType(userType)
        let schema = builder.build()
        #expect(schema.types["User"] != nil)
    }

    @Test("Build with no mutations returns nil mutation")
    func noMutations() {
        var builder = PrismGraphQLSchemaBuilder()
        builder.query("hello", type: .string) { _ in "world" }
        let schema = builder.build()
        #expect(schema.mutation == nil)
        #expect(schema.subscription == nil)
    }
}

@Suite("PrismGraphQLResolveInfo Tests")
struct PrismGraphQLResolveInfoTests {

    @Test("requireArg throws for missing argument")
    func requireArgMissing() {
        let info = PrismGraphQLResolveInfo(fieldName: "test", arguments: [:], context: nil, parentValue: nil)
        #expect(throws: PrismGraphQLExecutionError.self) {
            let _: String = try info.requireArg("name")
        }
    }

    @Test("requireArg returns value for existing argument")
    func requireArgExists() throws {
        let info = PrismGraphQLResolveInfo(
            fieldName: "test", arguments: ["name": "Alice"], context: nil, parentValue: nil)
        let name: String = try info.requireArg("name")
        #expect(name == "Alice")
    }
}

@Suite("PrismGraphQLValue Tests")
struct PrismGraphQLValueTests {

    @Test("toAny conversions")
    func toAnyConversions() {
        #expect(PrismGraphQLValue.string("hi").toAny() as? String == "hi")
        #expect(PrismGraphQLValue.int(5).toAny() as? Int == 5)
        #expect(PrismGraphQLValue.float(1.5).toAny() as? Double == 1.5)
        #expect(PrismGraphQLValue.boolean(true).toAny() as? Bool == true)
        #expect(PrismGraphQLValue.null.toAny() is NSNull)
        #expect(PrismGraphQLValue.variable("x").toAny() is NSNull)
        #expect(PrismGraphQLValue.enum("ACTIVE").toAny() as? String == "ACTIVE")
    }

    @Test("toAny list and object")
    func toAnyListAndObject() {
        let list = PrismGraphQLValue.list([.int(1), .int(2)])
        let arr = list.toAny() as? [Any]
        #expect(arr?.count == 2)

        let obj = PrismGraphQLValue.object(["key": .string("val")])
        let dict = obj.toAny() as? [String: Any]
        #expect(dict?["key"] as? String == "val")
    }

    @Test("resolveVariables replaces variable references")
    func resolveVariables() {
        let val = PrismGraphQLValue.variable("x")
        let resolved = val.resolveVariables(["x": 42])
        #expect(resolved as? Int == 42)
    }

    @Test("resolveVariables with missing variable returns NSNull")
    func resolveVariablesMissing() {
        let val = PrismGraphQLValue.variable("missing")
        let resolved = val.resolveVariables([:])
        #expect(resolved is NSNull)
    }

    @Test("resolveVariables in list")
    func resolveVariablesInList() {
        let val = PrismGraphQLValue.list([.variable("x"), .int(1)])
        let resolved = val.resolveVariables(["x": "hello"]) as? [Any]
        #expect(resolved?.first as? String == "hello")
    }

    @Test("resolveVariables in object")
    func resolveVariablesInObject() {
        let val = PrismGraphQLValue.object(["key": .variable("v")])
        let resolved = val.resolveVariables(["v": true]) as? [String: Any]
        #expect(resolved?["key"] as? Bool == true)
    }
}

@Suite("PrismGraphQLDocument Tests")
struct PrismGraphQLDocumentTests {

    @Test("operation(named:) finds correct operation")
    func operationNamed() throws {
        let parser = PrismGraphQLParser()
        let doc = try parser.parse("query Foo { hello } query Bar { world }")
        #expect(doc.operation(named: "Foo")?.name == "Foo")
        #expect(doc.operation(named: "Bar")?.name == "Bar")
        #expect(doc.operation(named: "Baz") == nil)
    }
}
