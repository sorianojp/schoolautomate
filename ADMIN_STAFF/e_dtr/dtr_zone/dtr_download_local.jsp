<%@ page language="java" import="utility.*,eDTR.StandAloneDTR,java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	var win;
	
	function DownloadDTRData(){
		//document.form_.download_dtr.value = "1";
		//document.form_.submit();
		var dateFr = document.form_.date_fr.value;
		var dateTo = document.form_.date_to.value;
		var includeDownloaded = document.form_.include_downloaded.checked;
		
		if(dateFr.length == 0 || dateTo.length == 0){
			alert("Please provide DTR record date range.");
			return;
		}
		
		if(includeDownloaded)
			includeDownloaded = "1";
		else
			includeDownloaded = "0";
		
		var pgLoc = "./dtr_download_local_popup.jsp?date_fr="+dateFr+"&date_to="+dateTo+"&include_downloaded="+includeDownloaded;
		win=window.open(pgLoc,"DownloadDTRData",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=yes');
		win.focus();
	}
	
</script>
<body bgcolor="#D2AE72">
<form action="dtr_download_local.jsp" method="post" name="form_">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: DTR Record Download Page ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" width="3%"></td>
			<td width="17%">DTR Record Date Range </td>
			<td width="80%">
				<input name="date_fr" type="text" class="textbox" tabindex="-1" value="<%=WI.fillTextValue("date_fr")%>"
					size="10" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" tabindex="-1" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" >
				<img src="../../../images/calendar_new.gif" border="0"></a>
				to 
				<input name="date_to" type="text" class="textbox" tabindex="-1" value="<%=WI.fillTextValue("date_to")%>"
					size="10" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" tabindex="-1" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td>
				<%
					String strTemp = null;
					if(WI.fillTextValue("include_downloaded").length() > 0)
						strTemp = " checked";
					else
						strTemp = "";
				%>
				<input type="checkbox" name="include_downloaded" value="1" <%=strTemp%>>
				<font size="1">Check to include downloaded data.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2"></td>
			<td>
				<a href="javascript:DownloadDTRData();"><img src="../../../images/download.gif" border="0"></a>
				<font size="1">Click to download DTR information.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
</form>
</body>