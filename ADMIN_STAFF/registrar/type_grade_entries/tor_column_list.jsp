<html>
<head>
<title>Encoding of grades taken from other schools</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelEdit(){
	location = "./stud_non_acad.jsp?stud_id="+ document.form_.stud_id.value;
}

function ReloadSection(){
	document.form_.subject.value="";
	ReloadPage();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value ="1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
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

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,enrollment.RegTOREncoding" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
//add security here.

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ADMIN STAFF-Registrar Management-TOR Encoding","stud_acad.jsp");
}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","TOR Encoding",request.getRemoteAddr(), 
														"stud_acad.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
	OfflineAdmission offlineAdm = new OfflineAdmission();
	Vector vStudBasicInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	RegTOREncoding TOREnc = new RegTOREncoding();
	String strPageAction = WI.fillTextValue("page_action");

	
	if (WI.fillTextValue("stud_id").length() > 0){
		vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("stud_id"));
		if (vStudBasicInfo == null){
			strErrMsg = offlineAdm.getErrMsg();
		}		
		
		if (strPageAction.compareTo("1") == 0){
			vRetResult = TOREnc.operateOnColumnList(dbOP,request,1);
			if (vRetResult != null)
				strErrMsg = " TOR Encoding Column added successfully";
			else
				strErrMsg = TOREnc.getErrMsg();
		}
	}
if ( vStudBasicInfo != null) {
	vRetResult =  TOREnc.operateOnManualEncoding(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = TOREnc.getErrMsg();
	
}

%>
<body bgcolor="#D2AE72">
<form action="./tor_column_list.jsp" method="post" name="form_" id="form_">
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" > 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENCODING OF GRADES TAKEN FROM OTHER SCHOOL ::::</strong></font></strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="2">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size = \"3\" color=\"#FF0000\"><strong>","</strong></font>","")%> </td>
    </tr>
    <tr > 
      <td width="3%" height="18">&nbsp;</td>
      <td width="97%">Student ID : 
        <input name="stud_id" type="text" class="textbox" readonly="yes" value="<%=WI.fillTextValue("stud_id")%>" size="16" maxlength="16"></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2">&nbsp; </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="45%" height="25"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong>STUDENT NAME</font> :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%" valign="top">COURSE : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" valign="top"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong></font>YEAR LEVEL : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td valign="top">MAJOR : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><hr size="1" noshade> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>COLUMN NAME</td>
      <td height="25">COLUMN WIDTH</td>
    </tr>
    <%	int iCount = Integer.parseInt(WI.getStrValue(request.getParameter("num_column"),"0"));
	if (vRetResult.size() < 6) {
	
 	for (int i = 1; i <=iCount ; i++) {%>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%">&nbsp;</td>
      <td width="5%"><div align="right"><%=i%>)</div></td>
      <td width="43%"><input name="column_name<%=i%>" type="text" size="48" maxlength="64"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value=></td>
      <td width="42%" height="25"><input name="column_width<%=i%>" type="text" size="2" maxlength="2"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
      </td>
    </tr>
<%		} //end for loop
}else{
	for (int j = 5,k = 1; k <= iCount; k++, j+=3){
%>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%">&nbsp;</td>
      <td width="5%"><div align="right"><%=k%>)</div></td>
      <td width="43%">
	  <% if ( j < vRetResult.size()) strTemp = (String)vRetResult.elementAt(j);
	  	else strTemp = "";
	  %>
	  <input name="column_name<%=k%>" type="text" size="48" maxlength="64"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
      <td width="42%" height="25">
	  <% if ( j < vRetResult.size()) strTemp = (String)vRetResult.elementAt(j+1);
	  	else strTemp = "";
	  %>
	  <input name="column_width<%=k%>" type="text" size="2" maxlength="2"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
      </td>
    </tr>
<%} //end for loop
} // end if then else%>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25" colspan="3"><font color="#FF0000" size="1"><strong>Note: The total of all 
        the values of column width should be equal to 100.</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="center">
	  <% if (iAccessLevel > 1) {%>
	  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1">click 
          to save </font> <%}%></div></td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
    <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>

  <input type="hidden" name="page_action">
  <input type="hidden" name="main_index" value="<%=WI.fillTextValue("main_index")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="num_column" value="<%=WI.fillTextValue("num_column")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
