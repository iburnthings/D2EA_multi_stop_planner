Function GetCoords($DataGridViewRow) {
	Add-Type -AssemblyName System.Web
	#Pull data on Current System
	#check if row tag has coords
	If ($DataGridViewRow.tag -match '([^;]+);([^;]+);([^;]+)') {
		$X = $matches[1]
		$Y = $matches[2]
		$Z = $matches[3]
	}
	Else {
		# if not we pull data from EDSM
		# this will happen when we open a saved file
		$SystemName = $DataGridViewRow.Cells[0].Value
		$EncodedSystemName = [System.Web.HTTPUtility]::UrlEncode("{0}" -f $SystemName)

		$systemMetadata = Invoke-WebRequest $('https://www.edsm.net/api-v1/system?systemName={0}&showCoordinates=1' -f $EncodedSystemName) -UseBasicParsing

		If ($systemMetadata.content -match '{"name":"([^"]+)","coords":{"x":([\d.-]+),"y":([\d.-]+),"z":([\d.-]+)}') {
			$X = $matches[2]
			$Y = $matches[3]
			$Z = $matches[4]
		}
		Else {
			# if we didnt get a meaningfull reply the system name must be wrong
			[Microsoft.VisualBasic.Interaction]::MsgBox($('System [{0}] Unknown' -f $SystemName), 'OKonly', "Unknown System") | out-null
			$ErrorCount += 1
		}
	}

	Return $x, $y, $z
}
