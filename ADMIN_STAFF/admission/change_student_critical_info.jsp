<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)	
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="Javascript">
//for help
function WhatIsChangeCriticalInfo()
{
	var win=window.open("../../onlinehelp/whatis_changecriticalinfo.htm","HelpFile",
	'dependent=yes,width=300,height=300,screenX=200,screenY=300,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#D2AE72">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        STUDENT CRITICAL INFORMATION MODIFICATION PAGE ::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25"><a href="javascript:WhatIsChangeCriticalInfo();"><img src="../../images/online_help.gif" border="0"></a><font size="1"> 
      Help/instruction for the links below.</font></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25" align="right">Operation : </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./change_stud_critical_info_id.jsp">Change Student 
      ID</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./change_stud_critical_info_estatus.jsp">Change Student 
      Entry Status Information</a></td>
  </tr>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./change_stud_critical_info_other.jsp">Change Student 
      Entry Information (Other)</a></td>
  </tr>
<%if(false){%>
  <tr> 
    <td width="12%" height="25">&nbsp;</td>
    <td width="15%" height="25">&nbsp;</td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%"><a href="./change_stud_critical_info_cc.jsp">Create Student's 
      Change Course Information</a></td>
  </tr>
<%}%>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./change_stud_critical_info_yrlevel.jsp">Change Student's Year 
      level Information </a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./change_stud_critical_info_ncentry.jsp">Manage Student's Course,SY/SEM 
      Information</a></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./change_stud_critical_info_regular.jsp">Manage Student's Regularity Status </a></td>
  </tr>
<%if(strSchCode != null && strSchCode.startsWith("CIT") || true){%>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="./change_stud_critical_info_move_enrollment.jsp">Move Enrollment</a></td>
  </tr>
<%}%>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

</body>
</html>
