ForEach ($xmlpolicy in (Get-ChildItem .\XML\*.xml)) {
    $basename = ($XmlPolicy).BaseName
    $initialpolicy = ($XmlPolicy).FullName
    $binpolicy = $basename + ".bin"
    ConvertFrom-CIPolicy $initialpolicy .\BIN\$binpolicy
}