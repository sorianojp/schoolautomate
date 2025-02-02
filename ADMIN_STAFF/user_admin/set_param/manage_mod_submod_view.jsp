<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body bgcolor="#D2AE72">
<%@ page language="java" import="enrollment.Authentication,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsSchool = false;
if( (new utility.CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
int iCreateFor = 0;
if(!bolIsSchool)
	iCreateFor = 1;

if(strSchCode.startsWith("LHS") || strSchCode.startsWith("TSUNEISHI"))
	iCreateFor = 3;

Authentication auth = new Authentication();
auth.setIsSchool(bolIsSchool);

Vector vMainModList = auth.getMainModList(iCreateFor);
Vector vSubModList  = null;



%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MANAGE MODULE SUBMODULE PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      
    <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;</font></td>
    </tr>
</table>
  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <%
for(int i = 0; i < vMainModList.size(); ++i){%>
  <tr> 
    <td height="25" colspan="2" bgcolor="#FFFFDF" class="thinborder">&nbsp;&nbsp;<strong><%=(String)vMainModList.elementAt(i)%></strong></td>
  </tr>
  <%
vSubModList = auth.getMainSubModList((String)vMainModList.elementAt(i));
if(vSubModList != null && vSubModList.size() > 0) {
	for(int j = 0; j < vSubModList.size(); ++j){%>
  <tr> 
    <td width="48%" height="25" class="thinborder">&nbsp;<%=(String)vSubModList.elementAt(j)%></td>
    <td width="52%" class="thinborder">&nbsp;
	<%if(vSubModList.size() > (j + 1)) {%><%=(String)vSubModList.elementAt(++j)%><%}%></td>
  </tr>
  <%}//end of printing sub mod list.
  }else{//size is == 0%>
  <tr> 
    <td class="thinborder" colspan="2">&nbsp;&nbsp;************** NO SUB MODULE ***************</td>
  </tr>
  
<%}  
}//end of printing main mod list
%>
  <tr> 
    <td height="25" colspan="2" class="thinborder"><div align="center"> </div></td>
  </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
