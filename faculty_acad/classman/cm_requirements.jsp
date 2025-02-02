<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
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
	location = "./cm_requirements.jsp?sub_index="+document.form_.sub_index.value+"&filter_sub="+document.form_.filter_sub.value;
}

function PrintPg(){
	document.form_.page_action.value ="";
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_page.value ="1"
	this.SubmitOnce("form_");
}
function ChangeMainReq() {
	var strSelIndex = document.form_.sel_main_req.selectedIndex;
	if(strSelIndex == 0) 
		document.form_.main_req.value = "";
	else	
		document.form_.main_req.value = document.form_.sel_main_req[strSelIndex].text;
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSubjectReq" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
//add security here.

if (WI.fillTextValue("print_page").compareTo("1") == 0){ %>
	<jsp:forward page="./cm_requirements_print.jsp" />
<% return ;}



try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Requirements","cm_requirements.jsp");
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
														"cm_requirements.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
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
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
CMSubjectReq cm = new CMSubjectReq();
String strPageAction = WI.fillTextValue("page_action");

if (strPageAction.compareTo("0")==0) {
	vRetResult = cm.operateOnCMSubjReq(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = " Requirement successfully removed";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cm.operateOnCMSubjReq(dbOP,request,1);
	if (vRetResult != null)
		strErrMsg = " Requirement successfully added";
	else
		strErrMsg = cm.getErrMsg();
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cm.operateOnCMSubjReq(dbOP,request,2);
	if (vRetResult != null){
		strErrMsg = " Requirement successfully edited";
		strPrepareToEdit = "";
	}else
		strErrMsg = cm.getErrMsg();
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = cm.operateOnCMSubjReq(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = cm.getErrMsg();
}
%>
<body bgcolor="#93B5BB">
<form action="./cm_requirements.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="header">
    <tr bgcolor="#6A99A2"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          COURSE REQUIREMENT MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td> <strong>FILTER CODE</strong></td>
      <td width="8%"><input name="filter_sub" type="text" class="textbox" id="filter_sub"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("filter_sub")%>" size="5" maxlength="5" ></td>
      <td width="73%" height="26"> <a href="javascript:ReloadPage()"><img src="../../images/form_proceed.gif" width="81" height="21" border="0"></a> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="4%">&nbsp;</td>
      <td width="15%"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>SUBJECT 
        CODE</strong></font></td>
      <td height="25" colspan="2"><% 
	  	strTemp = WI.fillTextValue("filter_sub");
		if (strTemp.length() > 0) 
			strTemp = " and sub_code like '" + strTemp + "%'";
		strTemp = " from subject where is_del = 0 " + strTemp + " order by sub_code";
	  %> <select name="sub_index" onChange="ReloadPage()">
          <option value=""> Select Subject</option>
          <%=dbOP.loadCombo("distinct sub_index"," sub_code ", strTemp,WI.fillTextValue("sub_index"),false)%> </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" colspan="4"><hr size="1" noshade></td>
    </tr>
  </table>
<% if(WI.fillTextValue("sub_index").length() != 0) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="sub_data">
    <tr bgcolor="#FFFFFF"> 
      <td width="2%">&nbsp;</td>
      <td width="17%"><strong>SUBJECT TITLE :</strong> </td>
      <td width="81%" height="25"> <p><%=dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index"))%> </p></td>
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
		 <%=WI.getStrValue((String)vSubjPrereq.elementAt(j+1),",","","")+WI.getStrValue((String)vSubjPrereq.elementAt(j+2),"(",")","")%> 
		 <%}}%> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="myADTable">
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25"><strong>Select Main  Requirement from List </strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25"><select name="sel_main_req" onChange="ChangeMainReq();">
        <option value="" style="color:#FF0000;">&lt;Select Requirement&gt;</option>
        <%=dbOP.loadCombo("distinct MAIN_REQ","MAIN_REQ"," from CM_SUBJ_REQ where IS_VALID=1 order by CM_SUBJ_REQ.MAIN_REQ asc", request.getParameter("sel_main_req"), false)%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="4%">&nbsp;</td>
      <td width="96%" height="25"><strong>&nbsp;Name of the Requirement</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"> <%
	  	if (vEditInfo !=null) strTemp = (String)vEditInfo.elementAt(2);
	  	else strTemp = WI.fillTextValue("main_req");
	  %> <input name="main_req" type="text" size="64" maxlength="64"  class="textbox" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"> <strong>Sub Requirement</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"> <%
	  	if (vEditInfo !=null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(3),"");
	  	else strTemp = WI.fillTextValue("sub_req");
	  %> <input name="sub_req" type="text" size="64" maxlength="64"   class="textbox" value="<%=strTemp%>"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td height="25" align="center"> <%	if (iAccessLevel > 1){
		if (strPrepareToEdit.length()== 0){%> <a href="javascript:AddRecord()"><img src="../../images/add.gif" width="42" height="32" border="0"></a> 
        <font size="1">click to add record</font> &nbsp; <%}else{%> <a href="javascript:EditRecord()"><img src="../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click 
        to save changes</font> <%}}%> 
		<a href="javascript:CancelRecord()"><img src="../../images/cancel.gif" border="0"></a><font size=1>click to cancel entries</font>		</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td align="center">&nbsp;</td>
      <td height="25" align="center">&nbsp;</td>
    </tr>
  </table>
<%  vRetResult = cm.operateOnCMSubjReq(dbOP,request,4);
	if (vRetResult !=null){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" id="print">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5"><div align="right"><a href="javascript:PrintPg();"><img src="../../images/print.gif"  border="0"></a><font size="1">click 
          to print subject requirements</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborder">
    <tr bgcolor="#C2E0E0"> 
      <td height="25" colspan="5" class="thinborder"> <div align="center"><strong>LIST OF REQUIREMENTS 
          FOR <%="("+(dbOP.mapOneToOther("subject","is_del","0","sub_name"," and sub_index = " + WI.fillTextValue("sub_index"))).toUpperCase() +")"%></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=4){
		strTemp = (String)vRetResult.elementAt(i+2);
		strTemp2 =  (String)vRetResult.elementAt(i+3);
     
	 if (strTemp!= null) { %>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25" class="thinborder">&nbsp;</td>
      <td colspan="2" class="thinborderBOTTOM"><strong><%=strTemp%></strong></td>
      <td width="6%" class="thinborder"><% if (iAccessLevel > 1){%><a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/edit.gif"  border="0"></a><%}else{%>N/A <%}%></td>
      <td width="8%" class="thinborder"><% if (iAccessLevel == 2){%><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/delete.gif" width="55" height="28" border=0></a><%}else{%>N/A<%}%></td>
    </tr>
    <%} if (strTemp2 != null){%>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25" class="thinborder">&nbsp;</td>
      <td width="4%" class="thinborderBOTTOM">&nbsp;</td>
      <td width="80%" class="thinborderBOTTOM">&nbsp;<%=strTemp2%></td>
      <td width="6%" class="thinborder"><% if (iAccessLevel > 1){%><a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/edit.gif"  border="0"></a><%}else{%>N/A <%}%></td>
      <td width="8%" class="thinborder"><% if (iAccessLevel == 2){%><a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../images/delete.gif" width="55" height="28" border=0></a><%}else{%>N/A <%}%></td>
    </tr>
    <%}
	}//end for loop%>
  </table>
<%}
} // if sub_index  selected%>
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
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>