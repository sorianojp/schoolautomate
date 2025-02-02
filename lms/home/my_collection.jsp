<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	var pgLoc = "./my_collection_print.jsp";
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ClearEntry() {
	document.form_.accession_no.value = "";
	document.form_.my_note.value ="";
}
function ViewDetail(strAccessionNo) {
//popup window here. 
	var pgLoc = "../search/collection_details.jsp?accession_no="+escape(strAccessionNo);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=600,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function Reserve(strAccessionNo) {
	alert("Service is in Progress");
}

function focusID() {
	document.form_.accession_no.focus();
}
function PageAction(strAction, strIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strIndex;
	document.form_.submit();
}
</script>
<body bgcolor="#F2DFD2" onLoad="focusID();">
<%@ page language="java" import="utility.*,lms.LmsMyHome,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;

	if( (String)request.getSession(false).getAttribute("userId") == null) {
		//do not proceed - proceed to login.
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-MY Home - My Collection","my_collection.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
LmsMyHome myHome = new LmsMyHome();
Vector vRetResult = null;
int[] aiMaxBookAllowed = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(myHome.operateOnMyCollection(dbOP, request,Integer.parseInt(strTemp)) == null) {
		strErrMsg = myHome.getErrMsg();
	}else {
		if(strTemp.compareTo("0") == 0) 
			strErrMsg = "Collection information removed.";
		else
			strErrMsg = "Collection information added.";
	}
}
//view all. 
vRetResult = myHome.operateOnMyCollection(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = myHome.getErrMsg();
else if(vRetResult != null) {
	aiMaxBookAllowed = myHome.maxBookListAllowed(dbOP, (String)request.getSession(false).getAttribute("userId"),true);
	if(aiMaxBookAllowed == null) 
		strErrMsg = myHome.getErrMsg();
}
%>
<form action="./my_collection.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MY COLLECTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
 <%
 if(aiMaxBookAllowed != null){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><strong><font size="3">MAX ALLOWED BOOK : <%=aiMaxBookAllowed[0]%>, You can add <%=aiMaxBookAllowed[1]%> more book(s) to your Collection list.</font></strong></td>
    </tr>
 <%}%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%">Accession No</td>
      <td width="83%"><input name="accession_no" type="text" size="24" value="<%=WI.fillTextValue("accession_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Special Note</td>
      <td><input name="my_note" type="text" size="80" maxlength="256" value="<%=WI.fillTextValue("my_note")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; <a href='javascript:PageAction("1","");'><img src="../images/add.gif" border="0"></a> 
        <font size="1">Click to add the book to collection list.<a href='javascript:ClearEntry();'> 
        <img src="../../images/clear.gif" border="1"></a> <font size="1">Click 
        to clear entries.</font>
<%if(vRetResult != null){%>
		<a href='javascript:PrintPg();'><img src="../images/print_recommend.gif" border="0"></a> 
        Click to print collection list.
<%}%>		
		<br>
        </font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">SPECIAL 
          NOTE</font></strong></div></td>
      <td width="15%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COLLECTION 
          TYPE </strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>ACCESSION 
          NO. / BARCODE</strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>::: 
          TITLE ::: <br>
          SUB TITILE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>AUTHOR</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>BOOK 
          STATUS</strong></font></div></td>
      <td class="thinborder" width="6%" align="center"><strong><font size="1">CIRCULATION 
        TYPE </font></strong></td>
      <td class="thinborder" width="6%" align="center"><strong><font size="1">LOCATION</font></strong></td>
      <td class="thinborder" width="6%"><div align="center"><strong><font size="1">REMOVE</font></strong></div></td>
      <td class="thinborder" width="6%"><div align="center"><strong>View Detail 
          </strong> </div></td>
      <td class="thinborder" width="6%"><div align="center"><strong>Reserve</strong></div></td>
    </tr>
    <%
String[] astrConvertCheckOut = {" (Not for Checkout)"," (For Checkout)"};	
for(int i = 0; i < vRetResult.size(); i += 15){%>
    <tr>
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+1))%></font></td>
      <td height="25" class="thinborder" valign="top">&nbsp;<font size="1"><img src="../images/<%=(String)vRetResult.elementAt(i + 8)%>" border="1"> 
        &nbsp;<%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td class="thinborder" valign="top"><font size="1"> <%=(String)vRetResult.elementAt(i+2)%>/<%=(String)vRetResult.elementAt(i + 3)%> </font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;:::<%=(String)vRetResult.elementAt(i + 4)%>::: <br>
        &nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 9)%></font></td>
      <td class="thinborder" valign="top"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></font></td>
      <td class="thinborder" valign="top">&nbsp;
	  <%=(String)vRetResult.elementAt(10)%> 
	  <%=astrConvertCheckOut[Integer.parseInt((String)vRetResult.elementAt(11))]%> 
      </td>
      <td class="thinborder" valign="top">&nbsp;<%=(String)vRetResult.elementAt(12)%></td>
      <td class="thinborder" align="center" valign="top"><a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../images/delete_recommend.gif" border="0"></a></td>
      <td class="thinborder" align="center" valign="top"> <a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i + 2)%>");'><img src="../images/view_collection_dtls.gif" border="0"></a> 
      </td>
      <td class="thinborder" align="center" valign="top"> <a href='javascript:Reserve("<%=(String)vRetResult.elementAt(i + 2)%>");'><img src="../images/reserve.gif" border="0"></a> 
      </td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult not null.%>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>