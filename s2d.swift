import Foundation

struct DockerBuilder {
    let appName: String
    let swiftVersion: String
    let port: Int
    let dependencies: [String]
    
    func generateDockerfile() -> String {
        let deps = dependencies.joined(separator: " ")
        
        return """
        
        FROM swift:\(swiftVersion) as builder
        
        
        RUN apt-get update && apt-get install -y \\
            \(deps) \\
            && rm -rf /var/lib/apt/lists/*
        # Копируем исходный код
        WORKDIR /ql7-bank-server
        COPY . .
        
        
        RUN swift build -c release
        
        
        FROM ubuntu:latest
        WORKDIR /app
        
      
        COPY --from=builder /app/.build/release/\(appName) .
        
        
        EXPOSE \(port)
        
        
        CMD ["./\(appName)"]
        """
    }
    
    func buildDockerImage() throws {
        let dockerfileContent = generateDockerfile()
        try dockerfileContent.write(toFile: "Dockerfile", atomically: true, encoding: .utf8)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["docker", "build", "-t", appName.lowercased(), "."]
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            throw DockerError.buildFailed
        }
    }
}

enum DockerError: Error {
    case buildFailed
}

let builder = DockerBuilder(
    appName: "ql7bank",
    swiftVersion: "5.7",
    port: 8080,
    dependencies: ["libssl-dev", "zlib1g-dev"]
)

do {
    try builder.buildDockerImage()
    print("Docker образ успешно собран!")
} catch {
    print("Ошибка при сборке Docker образа: \(error)")
}