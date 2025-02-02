<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="JavaScript">
function ReloadPage() {
	document.form_.submit();
}
</script>
</head>
<%@ page language="java" import="utility.*,lms.MgmtLink,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	MgmtLink mgmtLink = new MgmtLink();
	Vector vRetResult = null;
	if(WI.fillTextValue("LINK_CATG_INDEX").compareTo("0") != 0 && WI.fillTextValue("show_").compareTo("1") == 0) {
		vRetResult = mgmtLink.operateOnLink(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = mgmtLink.getErrMsg();
	}
	


%>

<body bgcolor="#D3EBED">
<form action="./show_links.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0080C0"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LINKS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      
    <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;
	<font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="11%" height="25">Show Links </td>
      <td height="25" colspan="3"><select name="LINK_CATG_INDEX" onChange="ReloadPage();">
	  	  <option value="0">Select a link</option>
<%
strTemp =	WI.fillTextValue("LINK_CATG_INDEX");
if(strTemp.length() == 0 && WI.fillTextValue("show_").compareTo("1") == 0){%>
           <option value="" selected>ALL</option>
<%}else{%>
           <option value="">ALL</option>
<%}%>
          <%=dbOP.loadCombo("LINK_CATG_INDEX","CATEGORY"," from LMS_LINK_CATG order by CATEGORY asc",
		  	WI.fillTextValue("LINK_CATG_INDEX"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="18" colspan="5" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
<%
String strLinkCatgName = null;
if(vRetResult != null && vRetResult.size() > 0) {

	for(int i = 0; i < vRetResult.size();){
		strLinkCatgName = (String)vRetResult.elementAt(i + 2);%>
    <tr bgcolor="#F0FAFF"> 
      <td height="25" colspan="5" class="thinborderLEFTRIGHTBOTTOM"><strong><font color="#FF8080" size="3"><%=strLinkCatgName%></font></strong></td>
    </tr>
    <tr> 
      <td height="18" colspan="5" class="thinborderLEFTRIGHTBOTTOM">&nbsp;</td>
    </tr>
<%
for(int j =i; j < vRetResult.size(); j += 6) {
	if(strLinkCatgName.compareTo( (String)vRetResult.elementAt(j + 2)) != 0)
		break;
	%>
     <tr> 
      <td width="2%" height="25" class="thinborderLEFTBOTTOM">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><%=(String)vRetResult.elementAt(j + 3)%></td>
      <td width="26%" class="thinborderLEFTRIGHTBOTTOM">
	  <a href="<%=(String)vRetResult.elementAt(i + 4)%>" target="_blank">
	  <%=(String)vRetResult.elementAt(i + 4)%></a></td>
      <td width="49%" class="thinborderRIGHTBOTTOM"><%=(String)vRetResult.elementAt(j + 5)%></td>
    </tr>
	<%i = j + 6;}//end of for inner for loop

  }//end of outer for loop.
}//end if vRetResult != null
%>
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_" value="1">
  </form>

</body>
</html>
<%
dbOP.cleanUP();
%>