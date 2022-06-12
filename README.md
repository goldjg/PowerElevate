# Power Elevate
The purpose of the project is to make it easier to adopt the Principle of Least Privilege in Windows in terms of both provisioning and auditing.

## So what is on the roadmap?

1. Power Elevate Mapping Tool (PE-MAP) to generate a role profile which will allow the required access only, using the windows granular privileges, ACLs, BUILTIN roles, NTFS permissions etc - so if you don't know how to do something in a way that doesn't just mean adding the user to the local Administrators group, this is your goto tool.
2. Power Elevate Profiler Tool (PE-PROF) will generate a profile in JSON or YAML format that can be consumed by Power Elevate components for provisioning, deprovisioning and auditing.
3. Power Elevate Spyglass (PE-SPY) - Helps you to audit permissions that a user has on a particular device
4. Power Elevate Privilege Graph (PE-PG) - Surfaces insights on privileges provisioned across your user and device estate - just how privileged is a user across your entire enterprise?
5. Power Elevate Management Centre (PE-MAN) - Management Dashboard to access all tools/components/settings