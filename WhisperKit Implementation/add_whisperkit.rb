require 'xcodeproj'

project_path = './defog iOS.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Add WhisperKit package repository
package_url = "https://github.com/argmaxinc/WhisperKit.git"
package_req = Xcodeproj::Project::Object::XCRemoteSwiftPackageReference::Requirement.up_to_next_major_version("0.9.0")
package_ref = project.root_object.add_swift_package_repository(package_url, package_req)

# Add to target
target = project.targets.find { |t| t.name == "defog iOS" }
target.add_package_product_dependency(package_ref, "WhisperKit")

project.save
