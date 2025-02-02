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

function DeleteEmpType(index){
	document.form_.rem_emp_index.value = index;
	this.SubmitOnce("form_");	
}

function DeleteUser(index){
	document.form_.rem_user_index.value = index;
	this.SubmitOnce("form_");
}


function AddEmployee(){
	if (document.form_.emp_id.value.length == 0){
		alert("Please set the employee ID");
		return;
	}
	
 	document.form_.add_1.src = "../../../images/blank.gif";	
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}


function AddPosition(){
	 var strEmpIndex = document.form_.emp_type_index_.value;
	 
	 if (document.form_.emp_type_index.selectedIndex == 0){
	 	alert ("Please select position of employees");
		return;
	 }
	 
	 document.form_.add_2.src = "../../../images/blank.gif";
	 document.form_.page_action.value ="3";
	 document.form_.submit();
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
								"Admin/staff-HR-MEMO Management-Circulate memo","circulate_memo.jsp");

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
												"HR Management","MEMO MANAGEMENT",request.getRemoteAddr(),
												"circulate_memo.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home"," ../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetEmployees = null;
Vector vPositions  = new Vector();
Vector vVariables = null;
Vector vUserIndex = null;
	int iListCount = 0;


// list of user_index and employee type index.. 
String strUserIndex_ = "";
String strEmpTypeIndex_ ="";


int iAction =  Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
String strPrepareToEdit =  WI.fillTextValue("prepareToEdit");
hr.HRMemoManagement  mt = new hr.HRMemoManagement();


if (iAction == 0){
	if (mt.operateOnMemo(dbOP, request,0) != null){
		strErrMsg= " Required Personnel removed successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 1){
	if (mt.operateOnMemo(dbOP, request,1) != null){
		strErrMsg= " Required Personnel recorded successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}

if (WI.fillTextValue("view_all").equals("1")){
//	vRetResult = mt.operateOnMemo(dbOP, request,6);
//	if (vRetResult == null) 
//		strErrMsg = mt.getErrMsg();
}else{
//	vRetResult = mt.operateOnMemo(dbOP, request,4);
}

if (WI.fillTextValue("memo_index").length() > 0){
	vVariables = mt.parseMemoContent(dbOP, WI.fillTextValue("memo_index"));
	
										 
	if (WI.fillTextValue("page_action").equals("2")){ // add new user_index
		vUserIndex = mt.operateOnRecepients(dbOP, request, 2);
		
	} else if (WI.fillTextValue("page_action").equals("3")){ // add new user_index
		vUserIndex = mt.operateOnRecepients(dbOP, request, 3);
	}


}



%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./circulate_memo.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: CIRCULATE MEMO FOR PERSONNEL ::::</strong></font></div></td>
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
        <select name="memo_type_index" onChange="ReloadPage()">
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("memo_type_index","memo_type"," FROM hr_preload_memo_type order by memo_type",WI.fillTextValue("memo_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="17%" height="30" valign="bottom">MEMO  NAME </td>
      <td colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="3"><strong>
        <select name="memo_index" onChange="ReloadPage()" >
          <option value="">Select Memo</option>
          <%=dbOP.loadCombo("memo_index","memo_name",
	  				" FROM hr_memo_details where is_valid = 1 and is_del = 0 " + 
					WI.getStrValue(request.getParameter("memo_type_index"),
					"and  memo_type_index = ","","") + 
					" order by memo_name",WI.fillTextValue("memo_index"),false)%>
        </select>
      </strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23" colspan="3">&nbsp;</td>
    </tr>
<% if (vVariables != null && vVariables.size() > 0) {%> 
    <tr bgcolor="#DDE7FF">
      <td>&nbsp;</td>
      <td height="23"><strong>Variables : </strong></td>
      <td height="23" colspan="2">&nbsp; </td>
    </tr>
<% for (int k = 0; k < vVariables.size(); k++) {%> 
	<tr>
	  <td>&nbsp;</td>
	  <td height="23">&nbsp;
		<input type="hidden" name="var_<%=k%>" value="<%=(String)vVariables.elementAt(k)%>">
			<%=(String)vVariables.elementAt(k)%></td>
	  <td height="23" colspan="2">
		<input name="value_<%=k%>" type="text" class="textbox" 
		 onFocus="style.backgroundColor='#D3EBFF'"  
		 onBlur="style.backgroundColor='white'" 
		 value="<%=WI.fillTextValue("value_"+k)%>" size="64" maxlength="256">	  </td>
	</tr>
<%}%> 
    <tr >
      <td>&nbsp;<input type="hidden" value="<%=vVariables.size()%>" name="var_length"></td>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="2">&nbsp;</td>
    </tr>
<%}

if (WI.fillTextValue("memo_index").length() > 0) {%> 

    <tr >
      <td>&nbsp;</td>
      <td height="23"><strong><font color="#FF0000">Date of Sending </font></strong></td>
<%
	strTemp = WI.fillTextValue("date_send");
	if (strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%>
      <td width="17%" height="23">
	  <input name="date_send" type="text" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_send','/')"
	  onKeyUP="AllowOnlyIntegerExtn('form_','date_send','/')"
	  value="<%=strTemp%>" size="10" maxlength="10"> 
		<a href="javascript:show_calendar('form_.date_send');"><img src="../../../images/calendar_new.gif" border="0"></a></td>
	<% if (WI.fillTextValue("force_new_entry").equals("1")) 
			strTemp = "checked";
	 	else
			strTemp =""; %>
		
      <td width="62%"><input type="checkbox" name="force_new_entry" value="1" <%=strTemp%>>
	  	<font size="1"> create new entry (not duplicate)</font>
		
	<% if (WI.fillTextValue("add_new_employees").equals("1")) 
			strTemp = "checked";
	 	else
			strTemp =""; %>
		<input type="checkbox" name="add_new_employees" value="1" <%=strTemp%>>
	  	<font size="1"> add new employees only</font>
	  </td>
    </tr>
<%}%> 
    <tr >
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (WI.fillTextValue("memo_index").length() > 0) {%> 
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" bgcolor="#FAEDE2">&nbsp;</td>
      <td width="20%" height="23" bgcolor="#FAEDE2">&nbsp;</td>
      <td height="23" colspan="3" bgcolor="#FAEDE2">&nbsp;<span class="style1">&nbsp;SELECT RECIPIENT(S) OF THIS MEMO </span></td>
    </tr>
<% if (!WI.fillTextValue("view_5").equals("1")) {%>	
    <tr>
      <td width="4%">&nbsp;</td>
      <td height="43">SPECIFIC EMPLOYEE </td>
      <td width="15%" height="43"><input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName(1);ResetPosition();" value="<%=WI.fillTextValue("emp_id")%>"
		onBlur="style.backgroundColor='white'" size="16" ></td>
      <td width="8%"><a href="javascript:AddEmployee();"><img src="../../../images/add.gif" name="add_1" border="0"></a></td>
      <td width="53%">&nbsp;
      <label id="coa_info"></label></td>
    </tr>
<%}%> 
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="14%" height="30">POSITION </td>
      <td width="29%" height="30"><strong>
        <select name="emp_type_index">
          <option value="">Select Group / Position </option>
          <%=dbOP.loadCombo("emp_type_index","emp_type_name",
		  			" FROM hr_employment_type where is_del = 0 " +
				 " order by position_order, emp_type_name",WI.fillTextValue("emp_type_index"),false)%>
        </select>
      </strong></td>
      <td width="53%" height="30">
	  		<a href="javascript:AddPosition();"><img src="../../../images/add.gif" name="add_2" border="0"></a>	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="30">&nbsp;</td>
      <td height="30" colspan="2">&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="25" colspan="7" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES </strong></td>
      </tr>
<%
strErrMsg = null;

String strRemUserIndex = WI.fillTextValue("rem_user_index");
String strRemEmpIndex  = WI.fillTextValue("rem_emp_index");
int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));

if (vUserIndex != null && vUserIndex.size() > 0){
	iCount += vUserIndex.size() / 5;
}

String strIDNumber	   = null;	
String strUserIndex    = null;
String strEmpTypeIndex = null;
String strEmpName	   = null;
String strEmpTypeName  = null;


int i = 0;

boolean bolForceBreak = false;


for( i=0; i<iCount;){ 

	if (i == 0) {
%>
      <tr bgcolor="#33CCFF">
        <td width="42%" height="25" class="thinborder"><strong>&nbsp;(ID)&nbsp;&nbsp;EMPLOYEE NAMES</strong></td>
        <td width="8%" class="thinborder"><strong>&nbsp;REMOVE</strong></td>
        <td width="43%" class="thinborder"><strong>&nbsp;(ID)&nbsp;&nbsp;EMPLOYEE NAMES</strong></td>
        <td width="7%" class="thinborder"><strong>REMOVE</strong></td>
      </tr>	
<%}	
		strIDNumber     = WI.fillTextValue("user_id"+i);
		strUserIndex    = WI.fillTextValue("user_index"+i);
		strEmpTypeIndex = WI.fillTextValue("emp_type_index"+i);
		strEmpName  	= WI.fillTextValue("emp_name"+i);
		strEmpTypeName 	= WI.fillTextValue("emp_type_name"+i);

		if (strRemUserIndex.length() > 0 && 
				strRemUserIndex.equals(strUserIndex)){
			i++;
			continue;
		}

		if (strRemEmpIndex.length() > 0 &&
				strRemEmpIndex.equals(strEmpTypeIndex)){
			i++;
			continue;
		}

		if(strIDNumber.length() ==0 && vUserIndex!= null && vUserIndex.size()>0) {
			strUserIndex    = (String)vUserIndex.remove(0);
			strEmpTypeIndex = (String)vUserIndex.remove(0);
			strEmpTypeName  = (String)vUserIndex.remove(0);
			strIDNumber     = (String)vUserIndex.remove(0);
			strEmpName  	= (String)vUserIndex.remove(0);
		}

		if (strEmpTypeIndex != null && strEmpTypeIndex.length() > 0 && 
			!strEmpTypeIndex.equals("null") && vPositions.indexOf(strEmpTypeIndex) == -1){
			vPositions.addElement(strEmpTypeName);
			vPositions.addElement(strEmpTypeIndex);
						
			if (strEmpTypeIndex_.length() ==0) 
				strEmpTypeIndex_ += strEmpTypeIndex;
			else
				strEmpTypeIndex_ += "," + strEmpTypeIndex;
		}
		
		
		if (strEmpTypeIndex_.length() ==0){
			strEmpTypeIndex_ = strEmpTypeIndex;
		}else{
			strEmpTypeIndex_ += "," + strEmpTypeIndex;
		}
		
		if (strUserIndex_.length() ==0){
			strUserIndex_ = strUserIndex_;
		}else{
			strUserIndex_ += "," + strUserIndex;
		}
		
%> 
      <input type="hidden" name="user_id<%=iListCount%>" value="<%=strIDNumber%>">
      <input type="hidden" name="user_index<%=iListCount%>" value="<%=strUserIndex%>">
      <input type="hidden" name="emp_type_index<%=iListCount%>" value="<%=strEmpTypeIndex%>">
      <input type="hidden" name="emp_name<%=iListCount%>" value="<%=strEmpName%>">
	  <input type="hidden" name="emp_type_name<%=iListCount%>" value="<%=strEmpTypeName%>">
      <tr>
        <td height="25" class="thinborder">&nbsp; &nbsp;<%=strIDNumber%> &nbsp; &nbsp;<%=strEmpName%></td>
        <td class="thinborder"><a href='javascript:DeleteUser("<%=strUserIndex%>");' tabindex="-1"><img src="../../../images/delete.gif" border="0"></a></td>
		
		
<% 	 i++;
	++iListCount;
	strUserIndex ="";
	
	while(i<iCount) {

		strIDNumber     = WI.fillTextValue("user_id"+i);
		strUserIndex    = WI.fillTextValue("user_index"+i);
		strEmpTypeIndex = WI.fillTextValue("emp_type_index"+i);
		strEmpName  	= WI.fillTextValue("emp_name"+i);
		strEmpTypeName 	= WI.fillTextValue("emp_type_name"+i);

		if (strRemUserIndex.length() > 0 && 
				strRemUserIndex.equals(strUserIndex)){
			strUserIndex="";
			i++;
			continue;
		}

		if (strRemEmpIndex.length() > 0 &&
				strRemEmpIndex.equals(strEmpTypeIndex)){
			strUserIndex="";
			i++;
			continue;
		}

		if(strIDNumber.length() ==0 && vUserIndex!= null && vUserIndex.size()>0) {
			strUserIndex    = (String)vUserIndex.remove(0);
			strEmpTypeIndex = (String)vUserIndex.remove(0);
			strEmpTypeName  = (String)vUserIndex.remove(0);
			strIDNumber     = (String)vUserIndex.remove(0);
			strEmpName  	= (String)vUserIndex.remove(0);
		}

		if (strEmpTypeIndex != null && strEmpTypeIndex.length() > 0 && 
			!strEmpTypeIndex.equals("null") && vPositions.indexOf(strEmpTypeIndex) == -1){
			vPositions.addElement(strEmpTypeName);
			vPositions.addElement(strEmpTypeIndex);
						
			if (strEmpTypeIndex_.length() ==0) 
				strEmpTypeIndex_ += strEmpTypeIndex;
			else
				strEmpTypeIndex_ += "," + strEmpTypeIndex;
		}
		
		
		if (strEmpTypeIndex_.length() ==0){
			strEmpTypeIndex_ = strEmpTypeIndex;
		}else{
			strEmpTypeIndex_ += "," + strEmpTypeIndex;
		}
		
		if (strUserIndex_.length() ==0){
			strUserIndex_ = strUserIndex_;
		}else{
			strUserIndex_ += "," + strUserIndex;
		}

%>
      <input type="hidden" name="user_id<%=iListCount%>" value="<%=strIDNumber%>">
      <input type="hidden" name="user_index<%=iListCount%>" value="<%=strUserIndex%>">
      <input type="hidden" name="emp_type_index<%=iListCount%>" value="<%=strEmpTypeIndex%>">
      <input type="hidden" name="emp_name<%=iListCount%>" value="<%=strEmpName%>">
	  <input type="hidden" name="emp_type_name<%=iListCount%>" value="<%=strEmpTypeName%>">		
<%		
	  strIDNumber = "&nbsp; &nbsp;" + strIDNumber  +"&nbsp; &nbsp;" +strEmpName;
  	  ++iListCount;
	  i++;
	  break;	
	}
	
	if (strUserIndex.length() ==0) 
		strIDNumber	= "&nbsp;";

%>
		
        <td class="thinborder">&nbsp;<%=strIDNumber%></td>
        <td class="thinborder">
	<% if (!strIDNumber.equals("&nbsp;")){%> 
		<a href='javascript:DeleteUser("<%=strUserIndex%>");' tabindex="-1"><img src="../../../images/delete.gif" border="0"></a><%}else{%><%=strIDNumber%> <%}%>	
		</td>
      </tr>
<%}%> 	  
 </table>
<%	if (vPositions!= null && vPositions.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" bgcolor="#F8F3E4" class="thinborder">&nbsp;&nbsp;<strong>Positions Added : </strong></td>
    </tr>
<%	i = 0;
	while (i < vPositions.size()) {%> 
    <tr>
      <td width="7%" height="25" align="right" class="thinborder">&nbsp;</td>
      <td width="35%" class="thinborderBOTTOM"><% if (i < vPositions.size()) {%> 
	  		<%=(String)vPositions.elementAt(i++)%>
	  	<%}else{%>&nbsp;<%}%> </td>
      <td width="8%" class="thinborder"><% if (i < vPositions.size()) {%>
        <a href="javascript:DeleteEmpType(<%=(String)vPositions.elementAt(i++)%>)"><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>&nbsp;<%}%> </td>
      <td width="7%" class="thinborder">&nbsp;</td>
      <td width="35%" class="thinborderBOTTOM"><% if (i < vPositions.size()) {%> 
	  		<%=(String)vPositions.elementAt(i++)%>
  	  <%}else{%>&nbsp;<%}%> </td>
      <td width="8%" class="thinborder"><% if (i < vPositions.size()) {%> 
		<a href="javascript:DeleteEmpType(<%=(String)vPositions.elementAt(i++)%>)"><img src="../../../images/delete.gif" border="0"></a>
  	  <%}else{%>&nbsp;<%}%> </td>
    </tr>
<%}%> 
  </table>
<%}
 }  // 
%> 

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
 <% if (WI.fillTextValue("memo_index").length()  > 0) {%> 
    <tr> 
      <td height="25" colspan="2" align="center"> 
        <% if (iAccessLevel > 1){%>        
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save all entries</font> 
        <%} // end iAccessLevel  > 1%></td>
    </tr>
<%}%> 
    <tr>
      <td height="20" colspan="2">&nbsp;</td>
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
<input type="hidden" name="list_count" value="<%=iListCount%>">
<input type="hidden" name="add_emp">
<input type="hidden" name="user_index_" value="<%=strUserIndex_%>">
<input type="hidden" name="emp_type_index_" value="<%=strEmpTypeIndex_%>">
<input type="hidden" name="rem_emp_index" value="">
<input type="hidden" name="rem_user_index" value="">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

