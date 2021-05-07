Register-VMManConfigurationProvider -Name file -Parameters Path -Code {
	param ($Parameters)
	
	Copy-Item -Path (Join-Path -Path $Parameters.Path -ChildPath '*') -Destination $Parameters.OutPath -Recurse -Force -ErrorAction Stop
}