<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	background-color: #9FBFD0;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TABLE.thinborderALL{
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelEdit(){
	location = "./stud_acad.jsp?stud_id="+ document.form_.stud_id.value;
}

function PageAction(strAction, strInfoIndex){
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value ="1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce('form_');
}

function viewList(table,indexname,colname,labelname){ 
	var loadPg = "../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}
-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,osaGuidance.Organization" %>
<%
	if(request.getSession(false).getAttribute("userIndex") == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
//add security here.

	try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.



//end of authenticaion code.
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vStudBasicInfo = null;
	Vector vRetResult = null;
	

	Organization cm = new Organization();
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String[] astrConvSem = {", Summer", ", 1st Semester",", 2nd Semester",",3rd Semester", ", 4th Semester"};

	String strStudID = (String)request.getSession(false).getAttribute("userId");
	request.setAttribute("userIndex",(String)request.getSession(false).getAttribute("userIndex"));

	vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if (vStudBasicInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {		
		vRetResult =  cm.searchStudentMembership(dbOP,request);
		if (vRetResult == null)
			strErrMsg = cm.getErrMsg();
	}
	
%>
<body>
<form action="./organizational_membership.jsp" method="post" name="form_" id="form_" onSubmit="SubmitOnceButton(this);">
<input name="stud_id" type="hidden" value="<%=strStudID%>"> 

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      STUDENT ORGANIZATIONS ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4">&nbsp;<%=WI.getStrValue(strErrMsg, "<font size=\"3\" color=\"#FF0000\">","</font>","")%></td>
    </tr>
  </table>
<% if (vStudBasicInfo != null) {%>
<!--
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><hr size="1"> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong>STUDENT NAME</font> :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%">COURSE : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong></font>YEAR LEVEL : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td>MAJOR : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr width="100%" size="1" noshade></td>
    </tr>
  </table>
-->
<%
 if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"><strong>&nbsp;Name of Organization </strong></td>
      <td><strong>&nbsp;Position</strong></td>
      <td><strong>&nbsp;School Year</strong> </td>
    </tr>
<% for (int i = 0 ; i< vRetResult.size(); i+=4){%>
    <tr> 
      <td width="43%" height="25">&nbsp;<%=(String)vRetResult.elementAt(i)%> </td>
      <td width="25%">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td width="32%">&nbsp;
	  		<%=(String)vRetResult.elementAt(i+2)%> - <%=(String)vRetResult.elementAt(i+3)%>	   </td>
    </tr>
<%} // end fro lopp%>
  </table>
<%}
} // end vStudBasicInfo != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25" bgcolor="#47768F">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="opner_form_name" value="form_">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="is_student" value="<%=WI.fillTextValue("is_student")%>">
</form>
</body>
</html>

