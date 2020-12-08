<?php 


class project {

public $projectName;
public $adminSG;

public function __construct($projectName,$adminSG = 'sg-us_gcp_ame_ena_gcp_admins') 
{

	$this->projectName = $projectName;
	$this->adminSG = $adminSG;
}

public function getProject() 
{

	return $this->projectName;

}

public function formatProject($project) 
{
		
}


}


class apply{

  	public $fileLocation;
	public $fileAdd; 
	public $file;

	public function __construct($fileLocation, $fileAdd) {
		$this->fileLocation = $fileLocation;
		$this->fileAdd = $fileAdd;
	}
	
	public function getLocation() {
		
		echo shell_exec('cat ' . $this->fileLocation);
	}

	public function setLocation() {

		file_put_contents($this->fileLocation, $this->fileAdd.PHP_EOL, FILE_APPEND | LOCK_EX);

	}
}

//$adminAppend = new apply($fileLocation="/tmp/testing.txt",$fileAdd="sg-us_gcp_ame_ena_gcp_admins");

//$append = $adminAppend->setLocation();
$projectName = shell_exec('gcloud config get-value project');
$admin = new project($projectName,$adminSG="sg-us_gcp_ame_ena_gcp_admins");
echo $admin->getProject().PHP_EOL;

