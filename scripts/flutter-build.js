const { execSync } = require("child_process");
const path = require("path");

// Save the current working directory
const originalDir = process.cwd();

try {
    // Change to the Flutter project directory
    const flutterProjectDir = "E:\\Code\\Flutter\\sappy\\sappy";
    console.log(`Changing directory to: ${flutterProjectDir}`);
    process.chdir(flutterProjectDir);

    // Run the Flutter commands
    console.log("Building and installing Flutter APK...");
    execSync("flutter build apk --release && flutter install", { stdio: "inherit" });

    console.log("Flutter APK built and installed successfully.");
} catch (error) {
    console.error("Error while building or installing Flutter APK:", error.message);
} finally {
    // Return to the original directory
    console.log(`Returning to original directory: ${originalDir}`);
    process.chdir(originalDir);
}