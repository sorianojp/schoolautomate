<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if(WI.fillTextValue("my_home").compareTo("1") == 0 ){
		bolMyHome = true;
	}
	String strSchCode = 
			WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
			
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.style1 {
	color: #0000FF;
	font-weight: bold;
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">


function RemoveUserID(){
	if(document.form_.emp_type_index.selectedIndex > 0){
		document.form_.emp_id.value="";
	}
}

function ResetPosition(){
	if(document.form_.emp_type_index.selectedIndex>0){
		document.form_.emp_type_index.selectedIndex = 0;
	}
}

function ClearViewAll(){
	if(document.form_.view_all.checked) 
		document.form_.view_all.checked = false;

	document.form_.page_action.value = "";		
	this.ReloadPage();
	
}

function ViewPerEmployee(){
	// uncheck the history.. 
	if(document.form_.view_5.checked) 
		document.form_.view_5.checked = false;

	document.form_.page_action.value = "";		
	this.ReloadPage();
}

function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
//		alert ("helloe world");
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
//	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewMandatoryTrainings(){
	var pgLoc = "./mandatory_trainings.jsp";
	var win=window.open(pgLoc,"UpdateWindow",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	this.SubmitOnce("form_");
}

function ReloadPage(){
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("form_");
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	this.SubmitOnce("form_");	
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","set_mandatory_training.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","TRAINING MANAGEMENT",request.getRemoteAddr(),
												"set_mandatory_training.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

Vector vRetResult = null;
Vector vEditInfo = null;

int iAction =  Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
String strPrepareToEdit =  WI.fillTextValue("prepareToEdit");
hr.HRMandatoryTrng  mt = new hr.HRMandatoryTrng();


if (iAction == 0){
	if (mt.operateOnRequireTraining(dbOP, request,0) != null){
		strErrMsg= " Required Personnel removed successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 1){
	if (mt.operateOnRequireTraining(dbOP, request,1) != null){
		strErrMsg= " Required Personnel recorded successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}

if (WI.fillTextValue("view_5").equals("1")) {
	vRetResult = mt.operateOnRequireTraining(dbOP, request,5);
	if (vRetResult == null) 
		strErrMsg = mt.getErrMsg();
}else if (WI.fillTextValue("view_all").equals("1")){
	vRetResult = mt.operateOnRequireTraining(dbOP, request,6);
	if (vRetResult == null) 
		strErrMsg = mt.getErrMsg();
}else{
	vRetResult = mt.operateOnRequireTraining(dbOP, request,4);
}





%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./set_mandatory_training.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: SET MANDATORY TRAINING FOR PERSONNEL ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30">TYPE OF TRAINING </td>
 	  <td width="79%" height="30">
        <select name="training_type_index" onChange="ReloadPage()">
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("TRAINING_TYPE_INDEX","TRAINING_TYPE"," FROM HR_PRELOAD_TRAINING_TYPE order by TRAINING_TYPE",WI.fillTextValue("training_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="29%" height="30" valign="bottom">TRAINING NAME / DESCRIPTION :</td>
      <td width="67%" valign="bottom"> 
<% if (!WI.fillTextValue("view_5").equals("1")) {%> 
<%if(!bolMyHome && iAccessLevel > 1){%>
	  <a href='javascript:viewMandatoryTrainings()'><img src="../../../images/update.gif" border="0"></a>
	  <font size="1">click to update mandatory training list </font>
<%}%>
<%}%> 	  
	  
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="2"><strong>
        <select name="mand_training_index" onChange="ReloadPage()" >
		<option value="">View All</option>
          <%=dbOP.loadCombo("MAND_TRAINING_INDEX","MAND_TRAINING_NAME",
	  				" FROM hr_mand_training_name where is_valid = 1 and is_del = 0 " + 
					WI.getStrValue(request.getParameter("training_type_index"),
					"and  TRAINING_TYPE_INDEX = ","","") + 
					" order by MAND_TRAINING_NAME",WI.fillTextValue("mand_training_index"),false)%>
        </select>
      </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td height="41">&nbsp;</td>
      <td height="41" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="4%" bgcolor="#FAEDE2">&nbsp;</td>
      <td width="20%" height="23" bgcolor="#FAEDE2">&nbsp;</td>
      <td height="23" colspan="3" bgcolor="#FAEDE2">&nbsp;<span class="style1">&nbsp;EXPECTED EMPLOYEES TO ATTEND </span></td>
    </tr>
<% if (!WI.fillTextValue("view_5").equals("1")) {%>	
    <tr>
      <td width="4%">&nbsp;</td>
      <td height="43">SPECIFIC EMPLOYEE </td>
      <td width="15%" height="43"><input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName(1);ResetPosition();" value="<%=WI.fillTextValue("emp_id")%>"
		onBlur="style.backgroundColor='white'" size="16" ></td>
      <td width="8%"><a href="javascript:EditRecord();"></a></td>
      <td width="53%">&nbsp;
      <label id="coa_info"></label></td>
    </tr>
<%}%> 
  </table>
<% if (!WI.fillTextValue("view_5").equals("1")) {%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="14%" height="30">POSITION </td>
      <td width="28%" height="30"><strong>
        <select name="emp_type_index" onChange="RemoveUserID()" >
          <option value="">Select Group / Position </option>
          <%=dbOP.loadCombo("emp_type_index","emp_type_name",
		  			" FROM hr_employment_type where is_del = 0 " +
				 " order by position_order, emp_type_name",WI.fillTextValue("emp_type_index"),false)%>
        </select>
      </strong></td>
      <td width="54%" height="30"><a href="javascript:EditRecord();"></a></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center"> 
        <% if (iAccessLevel > 1){%>        
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save all entries</font> 
        <%} // end iAccessLevel  > 1%></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%} // if not view old.. 
 if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">


    <tr bgcolor="#DBEEE0"> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>LIST 
          OF PERSONNEL WITH MANDATORY TRAINING </strong></td>
    </tr>
    <% 	String strCurrentTrainingIndex = "";
		for (int i=0 ; i < vRetResult.size(); i+= 7){
		
		if(!strCurrentTrainingIndex.equals((String)vRetResult.elementAt(i+4))){
			strCurrentTrainingIndex =(String)vRetResult.elementAt(i+4);
	%>
    <tr>
      <td height="25" colspan="4" bgcolor="#EEF2F9" class="thinborder">
	  <strong>TYPE / NAME OF TRAINING : 
	  	<font color="#0000FF"><%=(String)vRetResult.elementAt(i+5)%></font></strong></td>
    </tr>
	<%}%> 
    <tr> 
      <td width="6%" height="25" class="thinborder">&nbsp; </td>
      <td colspan="2" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),
 					(String)vRetResult.elementAt(i+2) + " : " + (String)vRetResult.elementAt(i+3))%>
		</td>
      <td width="8%" class="thinborder"> 
	  <%if (iAccessLevel == 2 && !WI.fillTextValue("view_all").equals("1")){%> 
	  	<a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%> N/A<%}%> </td>
    </tr>
    <%}%>
  </table>
<% } //vRetResult != null && vRetResult.size() > 0%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" class="thinborder">&nbsp;</td>
	  <% if (WI.fillTextValue("view_5").equals("1")) 
		  	strTemp = "checked";
		else
			strTemp = ""; %>
      <td width="44%" class="thinborderBOTTOM">
	  		<input type="checkbox" name="view_5" value="1" <%=strTemp%> onClick="ClearViewAll()">
      check to view old records </td>
	  
	  <% if (WI.fillTextValue("view_all").equals("1")) 
		  	strTemp = "checked";
		else
			strTemp = ""; %>	  
      
	  <td width="42%" class="thinborderBOTTOM">
	  <input type="checkbox" value="1" name="view_all" onClick="ViewPerEmployee()"
	  	<%=strTemp%>> 
	  view required training per employee detail </td>
      <td class="thinborderBOTTOM">&nbsp;</td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

