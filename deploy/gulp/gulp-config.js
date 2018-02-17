module.exports = function () 
{
    var srcRoot = "D:\\Projects\\Gary.Sitecore.Sntxrrr";
	var prefix = "sitecore901";
    var instanceRoot = "C:\\inetpub\\wwwroot\\" + prefix;
    var config = 
    {
        root: srcRoot,
        websiteRoot: instanceRoot + ".local",
        dataRoot: instanceRoot + ".local\\App_Data",
        sitecoreLibraries: instanceRoot + ".local\\bin",
        licensePath: srcRoot + "\\Deploy\\License\\Macaw\\App_Data\\license.xml",
        solutionName: "Sntxrrr",
        buildConfiguration: "Debug",
        buildPlatform: "Any CPU",
        buildToolsVersion: 15.0,
        publishPlatform: "AnyCpu",
        runCleanBuilds: false,
		sitecore9Config :
        {
            solrPort: "8983",
            prefix: prefix,
			sitecoreVersion: "9.0.1"
        }
	};
    return config;
}