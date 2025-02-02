<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSubjectRef" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;




//add security here.
	boolean bolIsStudent = WI.fillTextValue("is_student").equals("1");


	if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./cm_course_ref_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Course Reference Materials","cm_course_ref.jsp");

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
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(),
														"cm_course_ref.jsp");

if (bolIsStudent)
	iAccessLevel = 1;

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	Vector vRetResult = null;
	Vector vEditInfo = null;
	CMSubjectRef cm = new CMSubjectRef();
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");


if (strPageAction.compareTo("0")==0) {
	vRetResult = cm.operateOnSubjectRef(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Reference successfully removed";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cm.operateOnSubjectRef(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Reference successfully added";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cm.operateOnSubjectRef(dbOP,request,2);
	if (vRetResult != null){
		strErrMsg = " Reference successfully edited";
		strPrepareToEdit = "";
	}else
		strErrMsg = cm.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = cm.operateOnSubjectRef(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}
vRetResult = cm.operateOnSubjectRef(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = cm.getErrMsg();
}
 int iCtr = 0;
%>

<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.page_action.value ="";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value ="0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value ="1";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value ="2";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.page_action.value ="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.print_page.value ="";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	location = "./cm_course_ref.jsp?sub_index="+document.form_.sub_index.value+
	"&filter_sub="+document.form_.filter_sub.value;
}
function PrintPg(){

	document.form_.page_action.value ="";
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_page.value ="1"
	document.form_.h_sub_code.value = document.form_.sub_index[document.form_.sub_index.selectedIndex].text;
	this.SubmitOnce("form_");
}

</script>
</head>

<body bgcolor="#93B5BB">
<form action="cm_course_ref.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="myADTable">
    <tr bgcolor="#6A99A2">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE REFERENCE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td> <strong>FILTER CODE</strong></td>
      <td width="7%"><input name="filter_sub" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("filter_sub")%>" size="5" maxlength="5" ></td>
      <td width="72%" height="26"> <a href="javascript:ReloadPage()"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a>      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="4%">&nbsp;</td>
      <td width="17%"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>SUBJECT
        CODE</strong></font></td>
      <td height="25" colspan="2">
        <%
	  	strTemp = WI.fillTextValue("filter_sub");
		if (strTemp.length() > 0)
			strTemp = " and sub_code like '" + strTemp + "%'";
		strTemp = " from subject where is_del = 0 " + strTemp + " order by sub_code";
	  %>
        <select name="sub_index" onChange="ReloadPage()">
          <option value=""> Select Subject</option>
          <%=dbOP.loadCombo("distinct sub_index"," sub_code ", strTemp,WI.fillTextValue("sub_index"),false)%>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
<% if(WI.fillTextValue("sub_index").length() != 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="2%">&nbsp;</td>
      <td width="18%"><strong>SUBJECT TITLE :</strong> </td>
      <td width="80%" height="25"> <p><%=dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index"))%>
        </p></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td><strong>PREREQUISITES :</strong></td>
      <td height="25">
        <%
		Vector vSubjPrereq = new enrollment.CurriculumSM().viewAllRequisite(dbOP,WI.fillTextValue("sub_index"));
	  	for(int j= 0; j < vSubjPrereq.size(); j+=4){
	  	if (j == 0){%>
        <%=(String)vSubjPrereq.elementAt(j+1)+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%>
        <%}else{%>
        <%=WI.getStrValue((String)vSubjPrereq.elementAt(j+1),", ","","")+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%>
        <%}}%>
      </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
<% if (!bolIsStudent) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" id="entry_table">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">Type of Media</td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="2"> <%
if(vEditInfo!= null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = request.getParameter("mat_type_index");
%> <select name="mat_type_index" id="mat_type_index"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	strTemp, false)%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%">Title </td>
<%
if(vEditInfo!= null)
	strTemp = (String)vEditInfo.elementAt(4);
else
	strTemp = WI.fillTextValue("src_title");
%>
      <td width="86%"><input name="src_title" type="text"  class="textbox" id="src_title" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64" ></td>
    </tr>
    <tr>
      <td height="27">&nbsp;</td>
      <td>Author</td>
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("author");
%>
      <td><input name="author" type="text"  class="textbox"  value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="32" maxlength="64" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Edition No.</td>
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("edition");
%>
      <td><input name="edition" type="text"  class="textbox" id="edition"  value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="3" maxlength="2"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Remarks</td>
<%
if(vEditInfo!= null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
else
	strTemp = WI.fillTextValue("remarks");
%>
      <td><textarea name="remarks" cols="48" rows="2"   class="textbox" maxlength="256" onKeyUp="return isMaxLen(this)"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
<%//System.out.println(vEditInfo);
if(vEditInfo!= null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
else
	strTemp = WI.fillTextValue("avail_in_lib");

if (strTemp == null || strTemp.length() == 0)
	strTemp  = "";
else
	strTemp = "checked";


%>
      <td><input type="checkbox" name="avail_in_lib" value="1" <%=strTemp%>>
        check if available in library</td>
    </tr>
    <tr>
      <td colspan="3"> <div align="center">
          <%
 	strTemp = strPrepareToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <a href="javascript:AddRecord()"><img border="0" src="../../images/add.gif" width="42" height="32"></a>
          <font size="1">click to add record</font>
          <%     }
  }else{ %>
          <a href="javascript:EditRecord()"><img src="../../images/edit.gif" width="40" height="26" border="0"></a>
          <font size="1">click to save changes </font><a href='javascript:CancelRecord();'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%  } // not bol IsStudent
	if (vRetResult != null){%>
 <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#BDD5DF">
      <td height="30" colspan="5" class="thinborder"><div align="center"><strong>LIST
          OF COURSE REFERENCES</strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=9) {
		if (vRetResult.elementAt(i+1) != null){
	%>
    <tr bgcolor="#EFEFEF">
      <td width="1%" height="19" class="thinborder">&nbsp;</td>
      <td colspan="4" class="thinborderBOTTOM"><strong><font color="#990000"><%=(String)vRetResult.elementAt(i+2)%></font></strong></td>
    </tr>
	<%}%>
    <tr>
      <td height="25" class="thinborder">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong><%=(String)vRetResult.elementAt(i+4) + WI.getStrValue((String)vRetResult.elementAt(i+6)," ("," Edition)","")%></strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>Author : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"<br>Notes : ","","")%>
	  <br><% if (vRetResult.elementAt(i+8) != null){%>
	  	<img src="../../images/tick.gif">Available in Library
	  <%}%>
	  </td>
      <td width="5%" class="thinborderBOTTOM"> <% if (iAccessLevel > 1){ %> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../images/edit.gif" width="40" height="26" border="0">
        </a> <%}else{%>
        N/A
        <%}%> </td>
      <td width="10%" class="thinborderBOTTOM"> <% if (iAccessLevel == 2){ %> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        NA
        <%}%></td>
    </tr>
    <%} //end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" id="prn_table">
    <% for (int i = 0; i < vRetResult.size() ; i+=9) {
		if (vRetResult.elementAt(i+1) != null)
	%>
    <%} //end for loop%>
    <tr align="center">
      <td colspan="5">&nbsp;</td>
    </tr>
    <tr align="center">
      <td colspan="5"><font size="1"><a href="javascript:PrintPg()"><img src="../../images/print.gif" width="58" height="26" border="0"></a>click
        to print list</font></td>
    </tr>
  </table>
  <%}else if (bolIsStudent){ // if vretresult == null %>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
  <tr bgcolor="#FFFFFF">
      <td height="25" bgcolor="#FFFFFF">&nbsp; <font color="#FF0000" size="3">NO RECORD OF COURSE/SUBJECT REFERENCE</font></td>
  </tr>
</table>


<%}
} // if subject is selected%>
<table width="100%" border="0" cellpadding="2" cellspacing="0" id="footer">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="print_page"><input type="hidden" name="h_sub_code">
<input type="hidden" name="is_student" value="<%=WI.fillTextValue("is_student")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

