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
			if (eval('document.form_.ban_index'+i+'.checked == false'))
				eval('document.form_.benefit_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.benefit_index'+i+'.checked = false');
		}
	}
}

function UpdateBanSelection(){
	var iMaxDisplay = document.form_.max_display.value;
	if (document.form_.ban_all.checked) {
		for( var i =0 ; i < iMaxDisplay ; i++){
			if (eval('document.form_.benefit_index'+i+'.checked == false'))
				eval('document.form_.ban_index'+i+'.checked = true');
		}
	}else{
		for( var i =0 ; i < iMaxDisplay ; i++){
			eval('document.form_.ban_index'+i+'.checked = false');
		}
	}
}

function updateCheck(strCounter,strInfoIndex){
	if (strInfoIndex == 1){
		if (eval('document.form_.benefit_index'+strCounter+'.checked'))
			eval('document.form_.ban_index'+strCounter+'.checked=false');
	}else{
		if (eval('document.form_.ban_index'+strCounter+'.checked'))
			eval('document.form_.benefit_index'+strCounter+'.checked=false');
	}
}

function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function showList() {
	document.form_.showlist.value = '1';
	ReloadPage();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.id_num";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.id_num.value;
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
	document.form_.id_num.value = strID;
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
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","sal_ben_auto_insert.jsp.jsp");
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
														"sal_ben_auto_insert.jsp.jsp");
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
	if (hrAuto.insertAutoBenefitsLeave(dbOP, request) == -1) 
		strErrMsg = hrAuto.getErrMsg();
}
if(WI.fillTextValue("showlist").length() > 0) {
//	if(WI.fillTextValue("id_num").length() > 0){
		//int iTemp = hrAuto.autoForwardInsertLeaves(dbOP, request, WI.fillTextValue("id_num"));	
		//System.out.println("iTemp" + iTemp);
//	}
	
	vRetResult = hrAuto.getAutoBenefitsGovt(dbOP,request, true);
	if (vRetResult == null) 
		strErrMsg = hrAuto.getErrMsg();
		
}
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./sal_ben_auto_insert.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF" ><strong>:::: BENEFIT/INCENTIVE MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="90%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
      <td width="6%"><a href='./sal_ben_incent_mgmt_main.jsp'><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td height="25" colspan="2" align="center" class="fontsize10"><u><strong><font color="#FF0000">Employee Listing Filter </font></strong></u></td>
    </tr>
    <tr>
      <td width="16%" height="25" class="fontsize10">&nbsp;Employee ID </td>
      <td width="84%"><input type="text" name="id_num" value="<%=WI.fillTextValue("id_num")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"  onKeyUp="AjaxMapName(1);" >      
        (ID starts with)
        <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
        <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
      <label id="coa_info"></label>      </td></tr>
<!--    <tr> 
      <td height="25" class="fontsize10" width="16%"> &nbsp;Position</td>
      <td><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
-->    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td><select name="d_index">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    
    <tr>
      <td height="21">Civil Status</td>
			<%
				strTemp = WI.fillTextValue("cstatus");
			%>
			<td>
			<select name="cstatus">
				<option value="">ALL</option>
				<% if (strTemp.equals("1")) {%>
				<option value="1" selected>Single</option>
				<%}else{%>
				<option value="1">Single</option>
				<%} if (strTemp.equals("2")) {%>
				<option value="2" selected>Married</option>
				<%}else{%>
				<option value="2">Married</option>
				<%} if (strTemp.equals("3")) {%>
				<option value="3" selected>Divorced/Separated</option>
				<%}else{%>
				<option value="3" >Divorced/Separated</option>
				<%} if (strTemp.equals("4")) {%>
				<option value="4" selected>Widow/Widower</option>
				<%}else{%>
				<option value="4" >Widow/Widower</option>
				<%}
			if(bolAUF){
				if (strTemp.equals("5")) {%>
				<option value="5" selected>Annuled</option>
				<%}else{%>
				<option value="5">Annuled</option>
				<%} if (strTemp.equals("6")) {%>
				<option value="6" selected>Living Together</option>
				<%}else{%>
				<option value="6">Living Together</option>
				<%}
			}%>
			</select></td>
    </tr>
    <tr>
      <td height="10">Gender</td>
			<%
			strTemp = WI.fillTextValue("gender");
			%>
      <td><select name="gender">
				<option value="">ALL</option>
        <% if(strTemp.equals("0")){%>
        <option value="0" selected>Male</option>
        <%}else{%>
        <option value="0">Male</option>
        <%} if(strTemp.equals("1")){%>
        <option value="1" selected>Female</option>
        <%}else{%>
        <option value="1">Female</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>	
  
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	
<% if (vRetResult != null) {  
	int iMaxItem = Integer.parseInt((String)vRetResult.elementAt(2));
	int iShowItem = 1;
	
	if (Integer.parseInt((String)vRetResult.elementAt(1)) > 
		Integer.parseInt((String)vRetResult.elementAt(2)))
	
		strTemp = (String)vRetResult.elementAt(2);
	else 
		strTemp = (String)vRetResult.elementAt(1);
%>
    <tr> 
      <td height="25" colspan="5">
	  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="10%">Showing : </td>
          <td width="58%"><%=(String)vRetResult.elementAt(0)  + " - " +  strTemp + " of " + 
							(String)vRetResult.elementAt(2) %>			</td>
          <td width="32%">Jump To : 
		  	<select name = "jump_to" onChange="showList()">
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
      </table>
	  </td>
    </tr>

    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td colspan="4"><input type="checkbox" name="select_all" 
	  		value="1" onClick="UpdateSelection()"> Select All </td>
    </tr>
<%
 String strUserIndex = "";
 int iEmpCtr = Integer.parseInt((String)vRetResult.elementAt(0));
 for (int i = 3; i < vRetResult.size(); i+= 16, ++iCtr) {

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
    	<input type="hidden" name="ben_type_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+11)%>"> 
			<input type="hidden" name="user_index<%=iCtr%>" value="<%=strUserIndex%>"> 
			<input type="hidden" name="doe_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+10)%>"> 
		  <td width="26%" height="29">
	  <input type="checkbox" name="benefit_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+6)%>"		
	  onClick="updateCheck(<%=iCtr%>,1)">  
		
			<%=(String)vRetResult.elementAt(i+7)%></td>
	  <% strTemp = WI.fillTextValue("validity_date_fr" + iCtr);
		 if (strTemp.length()  == 0 || WI.fillTextValue("reload_page").equals("1")) 
		 	strTemp =(String)vRetResult.elementAt(i+9);
	  %>
      <td width="31%">
        Valid Date : &nbsp; From
       <input name="validity_date_fr<%=iCtr%>" type= "text" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeyUp="AllowOnlyIntegerExtn('form_','validity_date_fr<%=iCtr%>','/')" 
			value="<%=strTemp%>" size="11" style="font-size:12px;">
			<a href="javascript:show_calendar('form_.validity_date_fr<%=iCtr%>');" 
				title="Click to select date" onMouseOver="window.status='Select date';return true;" 
				onMouseOut="window.status='';return true;">
      <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
	  <% strTemp = WI.fillTextValue("validity_date_to" + iCtr);
		 if ( WI.fillTextValue("reload_page").equals("1")) 
		 	strTemp ="";
	  %>
      <td width="18%"> To 

        <input name="validity_date_to<%=iCtr%>" type= "text" class="textbox" id="validity_date_to" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeyPress=" AllowOnlyIntegerExtn('form_','validity_date_to<%=iCtr%>','/')" 
			value="<%=strTemp%>" size="11" style="font-size:12px;">
		<a href="javascript:show_calendar('form_.validity_date_to<%=iCtr%>');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
      <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td width="21%"><input type="checkbox" name="ban_index<%=iCtr%>" onClick="updateCheck(<%=iCtr%>,0)" 
	  					value="<%=(String)vRetResult.elementAt(i+6)%>"> Restrict Employee </td>
    </tr>
<%  }  %>

    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>



    <tr> 
      <td height="25" colspan="5"> 
	  	<div align="center">
	  	  <% if (iAccessLevel > 1){ %>	  	
	  	  <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save" onClick="document.form_.showlist.value='1'"></a>  <font size="1">click to save entries</font> 
	  	  
	  	  <a href="./sal_ben_auto_insert.jsp"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
	  	    to cancel and clear entries</font> 
	  	  
	  	  <%}%>		
      </div></td>
    </tr>
<%}%> 
  </table>
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
<input type="hidden" name="showlist">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
