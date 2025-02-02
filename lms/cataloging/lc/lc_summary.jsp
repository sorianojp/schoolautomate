<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>General Category Create</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>

</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrintPg() {
 	//document.bgColor = "#FFFFFF";
   	document.form_.hide_img.src = "../../../images/blank.gif";
   	document.form_.hide_text.value = "";
   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>

<%@ page language="java" import="utility.*,lms.CatalogDDC,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-DDC-SUMMARY","lc_summary.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","DDC NUMBERS",request.getRemoteAddr(),
														"lc_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	CatalogDDC ctlgDDC = new CatalogDDC();
	Vector vRetResult = null;

//view summary.
vRetResult = ctlgDDC.viewSummary(dbOP, true);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = ctlgDDC.getErrMsg();

//System.out.println(vRetResult);
//vRetResult = null;
%>

<body bgcolor="#DEC9CC">
<form action="./lc_summary.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#A8A8D5">
    <tr>
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          DDC SUMMARY PAGE :::: </strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(strErrMsg != null) {%>
    <tr>
      <td height="25" colspan="2"> &nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <%}%>
    <tr>
      <td width="49%" height="31">&nbsp; <a href="javascript:PrintPg();"><img name="hide_img" src="../../images/print.gif" border="0"></a> 
        <font size="1"><input type="text" readonly="yes" name="hide_text" class="textbox_noborder" style="font-size:10px;background-color:#DEC9CC" value="Click here to print this page" size="32"></font></td>
      <td width="51%" height="31" align="right"><font size="1">Date and time : <%=WI.getTodaysDateTime()%></font></td>
    </tr>
  </table>
<%
boolean bolIsBreak = false; //if true,, I should break from all loops and comeback to the top.

if(vRetResult != null && vRetResult.size() > 0) {
for(int i = 0; i < vRetResult.size();){bolIsBreak = false;
%>
  <table width="100%" cellpadding="0" cellspacing="0">
<%if(vRetResult.elementAt(i) != null){%>
   <tr>
      <td height="25" colspan="4" bgcolor="#FFFFDD" class="thinborderALL"><div align="center">
          <strong><%=(String)vRetResult.elementAt(i)%> (CLASS <%=(String)vRetResult.elementAt(i + 10)%>)</strong></div></td>
    </tr>
<%}//for loop for sub catetory.
vRetResult.setElementAt(null,i);
for(;i < vRetResult.size();){
//	if(vRetResult.elementAt(i) != null) //to to main loop for general category.
//		break;
	if(vRetResult.elementAt(i + 3) != null){%>
    <tr>
      <td width="4%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td colspan="3" class="thinborderRIGHT">SUB CATEGORY :::
	  <strong><%=(String)vRetResult.elementAt(i + 3)%> (CODE <%=(String)vRetResult.elementAt(i + 11)%>)</strong></td>
    </tr>
<%}//for loop sub category entry.
vRetResult.setElementAt(null,i + 3);
	for(; i < vRetResult.size();){
//		if(vRetResult.elementAt(i + 3) != null || vRetResult.elementAt(i) != null) //to to main loop for sub category.
//			break;
	if(vRetResult.elementAt(i + 6) != null){%>
		<tr>
		  <td height="25" width="4%" class="thinborderLEFT">&nbsp;</td>
		  <td width="6%" height="25">&nbsp;</td>

      <td colspan="2" class="thinborderRIGHT">SUB CATEGORY ENTRY ::: <%=(String)vRetResult.elementAt(i + 6)%> (RANGE: <%=(String)vRetResult.elementAt(i + 12)%>)</td>
		</tr>
	<%}//for loop sub category entry class.
	vRetResult.setElementAt(null,i + 6);
	for (; i < vRetResult.size(); i += 14){
		if(vRetResult.elementAt(i + 6) != null || vRetResult.elementAt(i + 3) != null || vRetResult.elementAt(i) != null) { //to to main loop for sub category.
			//i -= 10;
			bolIsBreak = true;
			break;
		}
	if(vRetResult.elementAt(i + 8) != null){%>
    <tr>
      <td height="25" width="4%" class="thinborderLEFT">&nbsp;</td>
      <td height="25" width="6%">&nbsp;</td>
      <td width="6%" height="25">&nbsp;</td>
      <td width="84%" class="thinborderRIGHT">SUB CATEGORY ENTRY CLASS ::: <%=(String)vRetResult.elementAt(i + 8)%> (CODE: <%=(String)vRetResult.elementAt(i + 13)%>)</td>
    </tr>
<%			}//print if not null.
		}//end of for loop to print sub category entry class
		if(bolIsBreak)
			break;
	}//end of for loop for sub category entry
	if(bolIsBreak)
		break;
}//end of sub category
%>
  </table>
<%}//for general Category - repeat table again.
}//only if vRetResult is not null
%>


</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
