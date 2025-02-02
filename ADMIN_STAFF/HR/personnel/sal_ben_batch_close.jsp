<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;

if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
		
//		alert (document.form_.jump_to.length);
//		alert (document.form_.jump_to.selectedIndex);		
		
		if (document.form_.jump_to.selectedIndex == document.form_.jump_to.length-1){
			document.form_.jump_to.selectedIndex--;	
		}
	}
	document.form_.submit();
}

function UpdateSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.select_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.benefit_index'+i+'.checked == false'))
				eval('document.form_.benefit_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.benefit_index'+i+'.checked = false');
		}
	}
}

function CopyDate(){
	var iMaxDisplay = document.form_.max_display.value;
	if(document.form_.validity_date_to0.value.length == 0)
		return;
	for (var i = 0 ; i < eval(iMaxDisplay);++i)
		eval('document.form_.validity_date_to'+i+'.value=document.form_.validity_date_to0.value');		
 
}

function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
///ajax here to load major..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
}



</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","sal_ben_batch_close.jsp.jsp");
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
int iAccessLevel = -1;
														
if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_batch_close.jsp.jsp");
}else{
  iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
	 											(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"hr_personnel_service_rec_benefit.jsp");
}														
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
						"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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

hr.hrAutoInsertBenefits hrAuto = new hr.hrAutoInsertBenefits();

if (WI.fillTextValue("page_action").equals("1")){
	if (hrAuto.getOpenBenefitIncentive(dbOP, request, 1) == null) 
		strErrMsg = hrAuto.getErrMsg();
}
if(WI.fillTextValue("searchEmployee").length() > 0){
	vRetResult = hrAuto.getOpenBenefitIncentive(dbOP,request, 4);
 	if (vRetResult == null) 
		strErrMsg = hrAuto.getErrMsg();
}
 %>

<body bgcolor="#663300" class="bgDynamic">
<form action="./sal_ben_batch_close.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INCENTIVE MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" align="right"> </td>
    </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td height="23" colspan="3"><font size="2" color="#FF0000"><strong><font size="1"><a href="./sal_ben_incent_mgmt_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font><%=WI.getStrValue(strErrMsg)%></strong></font></td>
			</tr>
			
			<tr>
				<td width="3%" height="24">&nbsp;</td>
				<td width="20%">Status</td>
				<td width="77%"><select name="pt_ft">
					<option value="">All</option>
					<%if (WI.fillTextValue("pt_ft").equals("0")){%>
					<option value="0" selected>Part-time</option>
					<%}else{%>
					<option value="0">Part-time</option>
					<%}if (WI.fillTextValue("pt_ft").equals("1")){%>
					<option value="1" selected>Full-time</option>
					<%}else{%>
					<option value="1">Full-time</option>
					<%}%>
				</select></td>
			</tr>
			<%if(bolIsSchool){%>
			<tr>
				<td height="24">&nbsp;</td>
				<td>Employee Category</td>
				<td>
			 <select name="employee_category">          
					<option value="">All</option>
					<%if (WI.fillTextValue("employee_category").equals("0")){%>
						<option value="0" selected>Non-Teaching</option>
					<%}else{%>
						<option value="0">Non-Teaching</option>				
					<%}if (WI.fillTextValue("employee_category").equals("1")){%>
						<option value="1" selected>Teaching</option>
					<%}else{%>
						<option value="1">Teaching</option>
					<%}%>
				 </select></td>
			</tr>
			<%}%>
			<% 	
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
			<tr> 
				<td height="24">&nbsp;</td>
				<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
				<td> <select name="c_index" onChange="ReloadPage();">
						<option value="">N/A</option>
						<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
			</tr>
			<tr> 
				<td height="25">&nbsp;</td>
				<td>Department/Office</td>
				<td>
				<select name="d_index">
						<option value="">ALL</option>
						<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
						<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
						<%}%>
					</select>	  </td>
			</tr>
			<tr> 
				<td height="10">&nbsp;</td>
				<td height="10">Employee ID </td>
				<td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" >
				<strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
					 <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	  				<label id="coa_info"></label>
				</strong>
				</td>
			</tr>
			<tr>
			  <td height="10">&nbsp;</td>
			  <td height="10">&nbsp;</td>
			  <td height="10">&nbsp;</td>
	  </tr>
			<tr>
			  <td height="10">&nbsp;</td>
			  <td height="10">&nbsp;</td>
			  <td height="10"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
          <font size="1">click to display benefits to close.</font></td>
	  </tr>
			<tr> 
				<td height="18" colspan="3"><hr size="1" color="#000000"></td>
			</tr>
		</table>		
<%if (vRetResult != null && vRetResult.size() > 3) {  %>
		<table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<% 
	int iMaxItem = Integer.parseInt((String)vRetResult.elementAt(2));
	int iShowItem = 1;
	
	if (Integer.parseInt((String)vRetResult.elementAt(1)) > 
		Integer.parseInt((String)vRetResult.elementAt(2)))
	
		strTemp = (String)vRetResult.elementAt(2);
	else 
		strTemp = (String)vRetResult.elementAt(1);
%>
    <tr> 
      <td height="25" colspan="5"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="10%">Showing : </td>
          <td width="58%"><%=(String)vRetResult.elementAt(0)  + " - " +  strTemp + " of " + 
							(String)vRetResult.elementAt(2) %>			</td>
          <td width="32%">Jump To : 
		  	<select name = "jump_to" onChange="SearchEmployee()">
	  			<% for (int k = 0 ; iShowItem < iMaxItem; k++,iShowItem+=50){
				
					if(iShowItem + 49 > iMaxItem ) 
						strTemp = Integer.toString(iMaxItem);
					else
						strTemp = Integer.toString(iShowItem + 49);
						
  				  if (WI.fillTextValue("jump_to").equals(Integer.toString(k))){
				%>
				<option value="<%=k%>" selected><%=iShowItem + " - " + strTemp%></option>
				<%}else{%> 
				<option value="<%=k%>"><%=iShowItem + " - " + strTemp%></option>								
				<%}
				}// end for loop%> 				
		  	</select>		  </td>
        </tr>
      </table></td>
    </tr>

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td><input type="checkbox" name="select_all" 
	  		value="1" onClick="UpdateSelection()"> Select All </td>
      <td>&nbsp;</td>
      <td><a href="javascript:CopyDate();">Copy First Date</a></td>
      <td>&nbsp;</td>
    </tr>
<%
 String strUserIndex = "";
 int iEmpCtr = Integer.parseInt((String)vRetResult.elementAt(0));
 for (int i = 3; i < vRetResult.size(); i+= 11, ++iCtr) {

  if (i==0 || !((String)vRetResult.elementAt(i)).equals(strUserIndex)) {
		strUserIndex = (String)vRetResult.elementAt(i);
  if (i != 0) {%>
    <tr>
   	  <td height="22" colspan="5">&nbsp; </td>
    </tr>	  
<%}%> 	  
    <tr>
      <td height="22" colspan="5">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"> 
	  	<tr> 
		  	<td width="50%" height="25"> <%=iEmpCtr++%>) Name :<font color="#FF0000"><strong><%=(String)vRetResult.elementAt(i+1)%> </strong></font></td>	  
		  	<td width="50%">Date of Employment :<strong><font color="#0000FF"><%=(String)vRetResult.elementAt(i+2)%> </font></strong></td>
		<!--
			Office : <%//=(String)vRetResult.elementAt(i+5)%> &nbsp;&nbsp;&nbsp; 
			Position : <%//=(String)vRetResult.elementAt(i+3)%> &nbsp;&nbsp;&nbsp;  
			Date of Emp : <%//=(String)vRetResult.elementAt(i+2)%> 
		-->
	    </tr>
	  </table>   	  </td>
    </tr>

<%}%> 
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="16%" height="29">
	  <input type="hidden" name="user_index<%=iCtr%>" value="<%=strUserIndex%>"> 
		<input type="hidden" name="info_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+10)%>"> 
	  <input type="checkbox" name="benefit_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+6)%>">  <%=(String)vRetResult.elementAt(i+7)%>	  </td>
	  <% strTemp = WI.fillTextValue("validity_date_fr" + iCtr);
		 if (strTemp.length()  == 0 || WI.fillTextValue("reload_page").equals("1")) 
		 	strTemp =(String)vRetResult.elementAt(i+9);
	  %>
      <td width="36%">
        Valid Date : &nbsp;&nbsp;&nbsp; From : 
        <input name="validity_date_fr<%=iCtr%>" type= "text" class="textbox_noborder" id="validity_date_fr<%=iCtr%>" 
	  		value="<%=strTemp%>" size="10" readonly></td>
	  <% strTemp = WI.fillTextValue("validity_date_to" + iCtr);
		 if ( WI.fillTextValue("reload_page").equals("1")) 
		 	strTemp ="";
	  %>
      <td width="23%"> To 

        <input name="validity_date_to<%=iCtr%>" type= "text" class="textbox" id="validity_date_to<%=iCtr%>" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','validity_date_to<%=iCtr%>','/')"			
			onKeyUp="AllowOnlyIntegerExtn('form_','validity_date_to<%=iCtr%>','/')" 
			value="<%=strTemp%>" size="10">
		<a href="javascript:show_calendar('form_.validity_date_to<%=iCtr%>');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td width="21%">&nbsp; </td>
    </tr>
		<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"> 
	  	<div align="center">
	  	  <% if (iAccessLevel > 1){ %>	  	
	  	  <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>  <font size="1">click to save entries</font> 
	  	  
	  	  <a href="./sal_ben_batch_close.jsp"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
	  	    to cancel and clear entries</font> 
	  	  
	  	  <%}%>		
      </div></td>
    </tr>
  </table>
<%}%> 	
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="max_display"  value="<%=iCtr%>">
<input type="hidden" name="reload_page">
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
