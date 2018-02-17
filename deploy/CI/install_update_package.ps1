Param
(
[string] $sitepath,
[string] $siteurl,
[string] $packagepath,
[string] $include = '*.update',
[string] $exclude = ''
)

$packageDestFolder = $sitepath + '\sitecore\admin\Packages\';

New-Item -ItemType Directory -Force -Path $packageDestFolder

$scriptrootpath = $sitepath + '\sitecore\__install__\';

$scriptpath = $scriptrootpath + 'InstallPackages.aspx';
$scripturl = $siteurl + '/sitecore/__install__/InstallPackages.aspx';

$webconfigpath = $scriptrootpath + 'web.config';


# clear the packages folder
$packagewildcard = $packageDestFolder + "*";
Remove-Item $packagewildcard

# copy the new package to the folder
Get-ChildItem $packagepath -Include $include -Exclude $exclude -Recurse | % { Copy-Item $_.fullname $packageDestFolder }


$script = '<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="log4net" %>
<%@ Import Namespace="Sitecore.Data.Engines" %>
<%@ Import Namespace="Sitecore.Data.Proxies" %>
<%@ Import Namespace="Sitecore.SecurityModel" %>
<%@ Import Namespace="Sitecore.Update" %>
<%@ Import Namespace="Sitecore.Update.Installer" %>
<%@ Import Namespace="Sitecore.Update.Installer.Exceptions" %>
<%@ Import Namespace="Sitecore.Update.Installer.Installer.Utils" %>
<%@ Import Namespace="Sitecore.Update.Installer.Utils" %>
<%@ Import Namespace="Sitecore.Update.Metadata" %>
<%@ Import Namespace="Sitecore.Update.Utils" %>
<%@ Import Namespace="Sitecore.Update.Wizard" %>
<!-- https://github.com/kevinobee/Sitecore.Ship/blob/develop/src/Sitecore.Ship.Infrastructure/Update/UpdatePackageRunner.cs  -->
<%@ Language=C# %>
   <script runat="server" language="C#">
       public void Page_Load(object sender, EventArgs e)
       {
           string[] extensions = { ".update", ".zip" };
           var files = Directory.GetFiles(Server.MapPath("/sitecore/admin/Packages"), "*.*", SearchOption.AllDirectories)
                                         .Where(f => extensions.Contains(new FileInfo(f).Extension.ToLower())).ToArray();
           Sitecore.Context.SetActiveSite("shell");
           using (new SecurityDisabler())
           {
               using (new ProxyDisabler())
               {
                   using (new SyncOperationContext())
                   {
                       foreach (var file in files)
                       {
                           var result = Install(file);
                       }
                   }
               }
           }
       }
       protected string Install(string package)
       {           
           var logger = Sitecore.Diagnostics.LoggerFactory.GetLogger(this);
           string result;


           using (new ShutdownGuard())
           {
               
               logger.Info("Start installing Package: " + package);
               Response.Write(getTime() + " Start installing Package: " + package + "<br>");
			   Response.Flush();

               var installationInfo = GetInstallationInfo(package);

               string historyPath = null;
               string error = string.Empty;
               List<ContingencyEntry> entries = null;

               //Run installation steps
               try
               {
                   entries = UpdateHelper.Install(installationInfo, logger, out historyPath);

                   logger.Info("Executing post installation actions.");
                   Response.Write(getTime() + " Executing post installation actions.<br>");
				   Response.Flush();

                   MetadataView metadata = PreviewMetadataWizardPage.GetMetadata(package, out error);

                   if (string.IsNullOrEmpty(error))
                   {
                       DiffInstaller diffInstaller = new DiffInstaller(UpgradeAction.Upgrade);
                       using (new SecurityDisabler())
                       {
					       //disable because you dont want this on production....
                           //diffInstaller.ExecutePostInstallationInstructions(package, historyPath, installationInfo.Mode, metadata, logger, ref entries);
                       }
                   }
                   else
                   {
                       logger.Info("Post installation actions error.");
                       Response.Write(getTime() + " Post installation actions error. <br>");

                       logger.Error(error);
                       Response.Write(getTime() + " " + error);
					   Response.Flush();
                   }

                   logger.Info("Executing post installation actions finished.");
                   Response.Write(getTime() + " Executing post installation actions finished. <br>");
				   Response.Flush();
               }
               catch (PostStepInstallerException exception)
               {
                   entries = exception.Entries;
                   historyPath = exception.HistoryPath;
                   throw;
               }
               finally
               {
                   try
                   {
                       SaveInstallationMessages(entries, historyPath);
                   }
                   catch (Exception)
                   {
                       logger.Error("Failed to record installation messages");
                       Response.Write(getTime() + " Failed to record installation messages <br>");
					   Response.Flush();
                       foreach (var entry in entries ?? Enumerable.Empty<ContingencyEntry>())
                       {
                           logger.Info(string.Format("Entry [{0}]-[{1}]-[{2}]-[{3}]-[{4}]-[{5}]-[{6}]-[{7}]-[{8}]-[{9}]-[{10}]-[{11}]",
                               entry.Action,
                               entry.Behavior,
                               entry.CommandKey,
                               entry.Database,
                               entry.Level,
                               entry.LongDescription,
                               entry.MessageGroup,
                               entry.MessageGroupDescription,
                               entry.MessageID,
                               entry.MessageType,
                               entry.Number,
                               entry.ShortDescription));
                       }
                       throw;
                   }
               }

               result = historyPath;
           }
           
           logger.Info("Finished installing Package: " + result);
           Response.Write(getTime() + " Finished installing Package: " + result + " <br>");
		   Response.Flush();

           return result;
       }

       private PackageInstallationInfo GetInstallationInfo(string packagePath)
       {
           var info = new PackageInstallationInfo
           {
               Mode = InstallMode.Install,
               Action = UpgradeAction.Upgrade,
               Path = packagePath,
			   ProcessingMode = ProcessingMode.Items
           };
           if (string.IsNullOrEmpty(info.Path))
           {
               throw new Exception("Package is not selected.");
           }
           return info;
       }

       private void SaveInstallationMessages(List<ContingencyEntry> entries, string historyPath)
       {
           string path = Path.Combine(historyPath, "messages.xml");
           //FileUtil.EnsureFolder(path);
           using (FileStream fileStream = File.Create(path))
           {
               new XmlEntrySerializer().Serialize(entries, (Stream)fileStream);
           }
       }

	   private string getTime()
	   {
		   return DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
	   }

   </script>'

New-Item $scriptpath -type file -value $script -force



$webconfig = '<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="InstallPackages.aspx" >
    <system.web>
      <httpRuntime executionTimeout="42000"/>
    </system.web>
  </location>
</configuration>'



New-Item $webconfigpath -type file -value $webconfig -force

#request the package installer script
#force to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$response = Invoke-WebRequest -Uri ($scripturl) -TimeoutSec 42000  -UseBasicParsing -outvariable htmlwebresponse
$response.Content
#and now we wait...

write $htmlwebresponses

# remove the installer stuff
Remove-Item $webconfigpath
Remove-Item $scriptpath
Remove-Item $scriptrootpath