# RoundhousE.Psake.Example
Use psake to build a C# project and use RoundHousE to 'kick' a NorthWind Database to your local SQLExpress Instance

Requires SQL or SQLExpress installed on your local environment.

#Instructions
From your powershell command line, navigate to base folder (RoundhousE.Psake.Example) and run "```.\build ?```" to view the available build options/commands.

```build```  or ```build default``` > Preforms a regular build by just compiling the solution.

```build cl``` > Performs a clean build; deleting all the files in bin folder.

```build rb``` > Performs a re-build (clean & build); a combination of the previous two.

```build rad``` > Runs the the DataMigration Project; Drops and Creates the Northwind database
