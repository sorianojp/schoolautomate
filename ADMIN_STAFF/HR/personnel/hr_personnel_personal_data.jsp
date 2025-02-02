<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if (WI.fillTextValue("print_page").equals("1")){
%>
		<jsp:forward page="./hr_personnel_personal_data_print.jsp" />
<%	return;}

///added code for HR/companies.
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

boolean bolIsGovernment = false;

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";
boolean bolAUF = strSchCode.startsWith("AUF");

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Personal Data</title>
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
</style>
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function ReloadTsType(){
<%if(bolAUF){%>
	if(document.staff_profile.teaching_staff.value.length == 0 || document.staff_profile.teaching_staff.value == '1'){
		document.staff_profile.is_acad_ntp.disabled = false;
		document.staff_profile.is_acad_jun.disabled = false;
		document.staff_profile.is_acad_sen.disabled = false;
		document.staff_profile.is_nonacad_jun.disabled = true;
		document.staff_profile.is_nonacad_sen.disabled = true;
	}
	else{
		document.staff_profile.is_acad_ntp.disabled = true;
		document.staff_profile.is_acad_jun.disabled = true;
		document.staff_profile.is_acad_sen.disabled = true;
		document.staff_profile.is_nonacad_jun.disabled = false;
		document.staff_profile.is_nonacad_sen.disabled = false;
	}
	
	document.staff_profile.is_acad_ntp.checked = "";
	document.staff_profile.is_acad_jun.checked = "";
	document.staff_profile.is_acad_sen.checked = "";
	document.staff_profile.is_nonacad_jun.checked = "";
	document.staff_profile.is_nonacad_sen.checked = "";
<%}%>
}
function PrintPg(){
	document.staff_profile.print_page.value = "1";
	this.SubmitOnce("staff_profile");
}
function Convert() {
	var pgLoc = "../../../commfile/conversion.jsp?called_fr_form=staff_profile&cm_field_name=height&lb_field_name=weight";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewInfo(){
	document.staff_profile.page_action.value = "0";
	document.staff_profile.showDB.value = "1";
	document.staff_profile.print_page.value = "0";	
	this.SubmitOnce("staff_profile");
}
function UpdateStatus(){
	document.staff_profile.page_action.value = "10";
	document.staff_profile.showDB.value = "1";
	document.staff_profile.print_page.value = "0";	
	this.SubmitOnce("staff_profile");
}
function viewEmpTypes(){
	var win=window.open("./hr_emp_type.jsp","myfile",'dependent=yes,width=900,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.showDB.value = "1";
	document.staff_profile.print_page.value = "0";	
	this.SubmitOnce("staff_profile");
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	document.staff_profile.print_page.value = "0";	
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function viewListOffices(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
	document.staff_profile.print_page.value = "0";	
	var loadPg = "../hr_updatelist_dept.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_staff_profilename=staff_profile" ;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	if (document.staff_profile.dob && document.staff_profile.dob.value.length > 0){
		UpdateAge();
	}
<% if(WI.fillTextValue("my_home").compareTo("1") != 0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.staff_profile.emp_id.value;
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
	document.staff_profile.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	this.viewInfo();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ReloadPage(){
	document.staff_profile.print_page.value = "0";	
	document.staff_profile.showDB.value="0";
	this.SubmitOnce("staff_profile");
}

function ChangeState(strFrmObject,strState){
	document.staff_profile.print_page.value = "0";	
	if (eval(strState) == 0) {
		eval("document."+strFrmObject+".readOnly =true");
		eval('document.'+strFrmObject+'.style.backgroundColor ="#CCCCCC"');

	}else {
		eval("document."+strFrmObject+".readOnly =false");
		eval("document."+strFrmObject+".style.backgroundColor ='#FFFFFF'");
	}
}

function UpdateAge(){
	var	strDateToday = "<%=WI.getTodaysDate(1)%>";
	document.staff_profile.age.value = 
		calculateAge(document.staff_profile.dob.value,strDateToday,true);
}
function viewCivilStatus(){
	document.staff_profile.print_page.value = "0";	
	var pgLoc = "./hr_emp_change_cs.jsp?emp_id=" + escape(document.staff_profile.emp_id.value)+"&my_home="
	+document.staff_profile.my_home.value;
	var win=window.open(pgLoc,"viewCivilStatus",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddMoreCollege() {
	document.staff_profile.print_page.value = "0";	
	if(document.staff_profile.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "../../user_admin/profile_add_more.jsp?emp_id="+escape(document.staff_profile.emp_id.value);
	var win=window.open(loadPg,"AddMoreCollege",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
///ajax here to load major..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.staff_profile.c_index[document.staff_profile.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_personnel_personal_data.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_personal_data.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
		
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
Vector vRetResult = null;
Vector vEmpRec = null;
boolean bNoError = false;
boolean bolNoRecord = false;
boolean bolFatalErr = false;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
Authentication auth = new Authentication();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"0"));

strTemp = WI.fillTextValue("emp_id");

if(WI.fillTextValue("new_").length() > 0) 
	request.getSession(false).removeAttribute("encoding_in_progress_id");

if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0) 	
	request.setAttribute("emp_id",strTemp);
	

if (strTemp.length()> 0 || WI.fillTextValue("new_").length() > 0){
	if (iAction == 10) {	// activate / deactivate employee for UI only
		iAction = hrPx.updateActive(dbOP, request);
		if (iAction == 0 ){
			strErrMsg = " Employee is set to active status";
		}else if (iAction == 1) {
			strErrMsg = " Employees is set to inactive status";
		}else if (iAction == -1){
			strErrMsg  = hrPx.getErrMsg();
		}
		
		iAction = 10;
	}

	if (iAction == 1 || iAction  == 2){
		vRetResult = hrPx.operateOnPersonalData(dbOP,request,iAction);
		switch(iAction){
			case 1:{ // add Record
				if (vRetResult != null) {
					strErrMsg = hrPx.getErrMsg();
					if(strErrMsg == null) {
						strErrMsg = " Operation Successful";
						if(request.getSession(false).getAttribute("encoding_in_progress_id") != null)
							strErrMsg += ". Employee ID: "+request.getSession(false).getAttribute("encoding_in_progress_id");
					}
				}
				else
					strErrMsg = hrPx.getErrMsg();
				break;
			}
		} //end switch
	} //  if (iAction == 1 || ..)
	
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
	vRetResult = hrPx.operateOnPersonalData(dbOP,request,0);

	if (vRetResult == null || vRetResult.size()==0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = hrPx.getErrMsg();
	}
}

boolean bolHasTeam = new ReadPropertyFile().getImageFileExtn("HAS_TEAMS","0").equals("1");


String strTeamIndex = null;
if(vEmpRec != null && bolHasTeam) {
	if((iAction == 1 || iAction == 2) ) {
		if(hrPx.operateOnTeamTsuneishi(dbOP, (String)vEmpRec.elementAt(0), request, iAction) == null)
			strErrMsg = hrPx.getErrMsg();
	}

	strTeamIndex = "select team_index from AC_TUN_TEAM_MEMBER where is_valid = 1 and member_index = "+
					(String)vEmpRec.elementAt(0);
	strTeamIndex = dbOP.getResultOfAQuery(strTeamIndex, 0);
}
if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vRetResult != null && vRetResult.size() > 0))  bolNoRecord = false;
	else bolNoRecord = true;

if ((request.getParameter("showDB") == null || 
	request.getParameter("showDB").compareTo("1") == 0) 
	&& (vEmpRec != null && vEmpRec.size() > 0))  bolFatalErr = false;
	else bolFatalErr = true;

boolean bolCleanUp = false;

if (!WI.fillTextValue("emp_id").equals(WI.fillTextValue("curr_emp_id")))
	bolCleanUp = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<!--<body class="bgDynamic" onLoad="FocusID();">-->

<form action="./hr_personnel_personal_data.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      PERSONAL DATA ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;
	  		<strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong>		</td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID :        
	  	<input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"  onKeyUp="AjaxMapName(1);"
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>" ></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="12%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="45%"><font size="1">
	  	  <input type="checkbox" name="new_" value="checked" <%=WI.fillTextValue("new_")%> onClick="document.staff_profile.emp_id.value='';document.staff_profile.submit();">Auto create Employee ID (for new ID)
	  <br>
<%
boolean bolResetYear = false;
if(strSchCode.startsWith("WNU"))
	bolResetYear = true;
else	
	bolResetYear = false;
%>
	  <b>ID Format is : YYxxx-XXXX - YY - 2 digit year, xxx - Security code, XXXX - counter <%if(bolResetYear){%> (Every year counter will be reset)<%}%></b>
	  </font>

	  
	  <br>
	  <label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="4" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
<% if (WI.getStrValue(strTemp,"").length() > 0 || WI.fillTextValue("new_").length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
<% if (vEmpRec != null && vEmpRec.size() > 0) {%>
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
			  <%if(bolAUF){%>
			  	<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLengthPT(dbOP,(String)vEmpRec.elementAt(0)), "Part-time years of service: ", "<br>", "")%>
				<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLengthFT(dbOP,(String)vEmpRec.elementAt(0)), "Full-time years of service: ", "<br>", "")%>
				<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0)), "Total years of service: ", "", "")%>
			  <%}else{%>
             	 <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
			  <%}%></font> 
            </td>
          </tr>
        </table>
<%}%>
        <br>
<table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
<% if (strSchCode.startsWith("UI")) {%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td>Status </td>
    <td width="16%"><strong>
	<%if (vEmpRec != null && vEmpRec.size() > 0){
		if (((String)vEmpRec.elementAt(21)).equals("1")) { 
	%>
		<font color="#FF0000" size="2">Active</font>
	<%}else{%>
		<font color="#0000FF" size="2">Inactive</font>
	    <%}
	}%>		
	</strong></td>
    <td width="64%">
<%if(!bolMyHome && iAccessLevel > 1){%>
		<a href='javascript:UpdateStatus()'><img border="0" src="../../../images/update.gif"></a> <font size="1">click to change active/inactive status </font>
<%}%>
	</td>
  </tr>
 <%}%> 
  <tr>
    <td height="25">&nbsp;</td>
    <td>Salutation</td>
    <td colspan="2">
<%
   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(23));
   }else{
   		if (!bolCleanUp) {
		   	strTemp  = WI.fillTextValue("salutation");
	   }else{
	   		strTemp=""; 
	   }
   }
%>
				<select name="salutation">
                <option value="">Select Salutation</option>
                <%=dbOP.loadCombo("SALUTATION_INDEX","SALUTATION"," FROM HR_PRELOAD_SALUTATION order by salutation",strTemp,false)%> </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_SALUTATION","SALUTATION_INDEX","SALUTATION","SALUTATION",
				"HR_INFO_PERSONAL","SALUTATION_INDEX", 
				" and HR_INFO_PERSONAL.is_del = 0","","salutation")'><img border="0" src="../../../images/update.gif"></a> 
              <font size="1">click to add/edit list of salutation</font>
<%}%>
		    </td>
  </tr>
  <tr> 
	<td height="18">&nbsp;</td>
	<td>&nbsp;</td>
	<td colspan="2" valign="bottom"><font size="1">First name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Middle 
	  name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Last 
	  name</font></td>
  </tr>
	  <tr> 
		<td  width="2%" height="25">&nbsp;</td>
		<td width="18%">Name 
<%
	if (bolCleanUp) strTemp = "";
	else strTemp = WI.fillTextValue("fname");

	if(!bolFatalErr) strTemp = (String)vEmpRec.elementAt(1);
%>		</td>
		<td colspan="2"> <input type="text" name="fname" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
		  &nbsp;&nbsp; 
<%if(!bolFatalErr) strTemp = WI.getStrValue((String)vEmpRec.elementAt(2));
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("mname");
else  strTemp = "";	
%> 
<input type="text" name="mname" value="<%=strTemp%>" class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> &nbsp;&nbsp; 
<%
if(!bolFatalErr) strTemp = (String)vEmpRec.elementAt(3);
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("lname");
else  strTemp = "";		
%> 
<input type="text" name="lname" value="<%=strTemp%>" class="textbox"
  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
	  </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>Gender</td>
            <td colspan="2"> <%
if(!bolFatalErr)strTemp = (String)vEmpRec.elementAt(4);
else  if (!bolCleanUp) 
	strTemp = WI.fillTextValue("gender"); 
else  strTemp = "";	
%>
			  <select name="gender">
			  	<option value="0">Male</option>
				<% if(strTemp.compareTo("1") == 0){%>
				<option value="1" selected>Female</option>
                <%}else{%>
				<option value="1">Female</option>
				<%}%>
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>Birth Date</td>
            <td colspan="2"> 
<%
	if(!bolFatalErr) strTemp = WI.getStrValue(vEmpRec.elementAt(5), "");
	else if (!bolCleanUp) 
		strTemp = WI.fillTextValue("dob");
	else  strTemp = "";
%> <input name="dob" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateAge();style.backgroundColor='white'" onKeyUP="AllowOnlyIntegerExtn('staff_profile','dob','/');UpdateAge()">
              <a href="javascript:show_calendar('staff_profile.dob',
	  <%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
              (mm/dd/yyyy)</font></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>Age</td>
            <td colspan="2"><input type="text" name="age" value="" class="textbox_noborder" readonly="yes"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"><font size="2">Date Hired</font></td>
            <td height="25" colspan="2"> 
<%	if(!bolFatalErr)  strTemp = WI.getStrValue(vEmpRec.elementAt(6), "");
	else if (!bolCleanUp) 
		strTemp = WI.fillTextValue("doe");
	else  strTemp = "";
%> 
	<input name="doe" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUP="AllowOnlyIntegerExtn('staff_profile','doe','/')">
              <a href="javascript:show_calendar('staff_profile.doe');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
              (mm/dd/yyyy)</font></td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25">End of Contract</td>
            <td height="25" colspan="2">
<%	
if(!bolFatalErr)  strTemp = WI.getStrValue(vEmpRec.elementAt(27), "");
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("dol");
else  strTemp = "";
%> 
	<input name="dol" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUP="AllowOnlyIntegerExtn('staff_profile','dol','/')">
              <a href="javascript:show_calendar('staff_profile.dol');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><font size="1"> 
              (mm/dd/yyyy)</font>
			<font style="font-weight:bold; color:#0000FF; font-size:10px;">
			(In case contract is not renewed, employee is considered as separated after specified date)
			</font>
			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Contact Nos.</td>
            <td height="25" colspan="2">
<% if(!bolFatalErr)  strTemp = WI.getStrValue((String)vEmpRec.elementAt(7));
	else  if (!bolCleanUp) 
		strTemp = WI.fillTextValue("tel_no");
	else  strTemp = "";		
%>  
	<input name="tel_no" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">              </td>
          </tr>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25" valign="top">Address</td>
            <td height="25" colspan="2">
<%if(!bolFatalErr) strTemp = WI.getStrValue((String)vEmpRec.elementAt(8));
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("address");
else
	strTemp = "";	
%>
	<textarea name="address" cols="32" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Email Address</td>
            <td height="25" colspan="2">
<% if(!bolNoRecord)
	strTemp = WI.getStrValue((String)vRetResult.elementAt(21));
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("email");
else
	strTemp = "";
%> <input name="email" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
    onblur="style.backgroundColor='white'"  value="<%=strTemp%>" size="64" maxlength="64"></td>
          </tr>
          <tr> 
            <td  colspan="4"height="10">&nbsp;</td>
          </tr>
        </table>
        <table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td height="20" colspan="3" bgcolor="#D9EDF9"> <strong>&nbsp;<font color="#CC3333">CURRENT EMPLOYMENT RECORD</font></strong> </td>
          </tr>
<% if (strSchCode.startsWith("AUF")) { 

 if(!bolFatalErr) 
		strTemp = WI.getStrValue((String)vEmpRec.elementAt(25));
	else if (!bolCleanUp) 
		strTemp = WI.fillTextValue("salary_grade"); 
	else
		strTemp = "";
%>
          <tr>
            <td height="25">&nbsp;</td>
            <td>&nbsp;Rank</td>
            <td>

<select name="salary_grade">
	<option value=""> Select Rank </option>
<%  Vector vTemp = new hr.HRInfoServiceRecord().getSalaryGradeDetail(dbOP); 

	if(vTemp != null && vTemp.size() > 0){
	 for(int i = 0; i < vTemp.size(); i += 5) {
	
		strTemp2 = (String)vTemp.elementAt(i + 1);
//				+ "  ("+(String)vTemp.elementAt(i + 2)+
//				WI.getStrValue((String)vTemp.elementAt(i + 3)," - ","","")+")";
	
		if(strTemp.equals((String)vTemp.elementAt(i))){
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected> <%=strTemp2%></option>
    <%}else{%>
         <option value="<%=(String)vTemp.elementAt(i)%>">  <%=strTemp2%></option>
    <%}
	}
}%>
 </select>			</td>
          </tr>
 <%}%> 
					<%if(bolIsSchool){%>
          <tr>
            <td height="25">&nbsp;</td>
            <td>Category</td>
            <td><% if(!bolFatalErr) 
	strTemp2 = (String)vEmpRec.elementAt(23);
else if (!bolCleanUp) 
	strTemp2 = WI.fillTextValue("teaching_staff"); 
else
	strTemp2 = "";
%>
              <select name="teaching_staff" onChange="ReloadTsType();">
                <option value="1">Academic Personnel </option>
                <% if (strTemp2.equals("0")){%>
                <option value="0" selected>Non Teaching Personnel</option>
                <%}else{%>
                <option value="0">Non Teaching Personnel </option>
                <%}%>
              </select></td>
          </tr>
		 <%if(bolAUF){%>
		  <tr>
		  		<td height="25">&nbsp;</td>
				<td>&nbsp;</td>
				<td>
					<%
						if(strTemp2.equals("0"))
							strTemp3 = "disabled";
						else
							strTemp3 = "";
					
						if(!bolFatalErr) 
							strTemp2 = (String)vEmpRec.elementAt(29);
						else if (!bolCleanUp) 
							strTemp2 = WI.fillTextValue("is_acad_ntp"); 
						else
							strTemp2 = "";
						
						if(strTemp2.equals("1"))
							strTemp4 = "checked";
						else
							strTemp4 = "";
					%>
					<input type="checkbox" name="is_acad_ntp" value="1" <%=strTemp3%> <%=strTemp4%>>Academic NTP<br>
					<%
						if(!bolFatalErr) 
							strTemp2 = (String)vEmpRec.elementAt(30);
						else if (!bolCleanUp) 
							strTemp2 = WI.fillTextValue("is_acad_jun"); 
						else
							strTemp2 = "";
						
						if(strTemp2.equals("1"))
							strTemp4 = "checked";
						else
							strTemp4 = "";
					%>
					<input type="checkbox" name="is_acad_jun" value="1" <%=strTemp3%> <%=strTemp4%>>Academic Junior Staff<br>
					<%
						if(!bolFatalErr) 
							strTemp2 = (String)vEmpRec.elementAt(31);
						else if (!bolCleanUp) 
							strTemp2 = WI.fillTextValue("is_acad_sen"); 
						else
							strTemp2 = "";
						
						if(strTemp2.equals("1"))
							strTemp4 = "checked";
						else
							strTemp4 = "";
					%>
					<input type="checkbox" name="is_acad_sen" value="1" <%=strTemp3%> <%=strTemp4%>>Academic Senior Staff<br>
					
					<%
						if(strTemp2.equals("1"))
							strTemp3 = "disabled";
						else
							strTemp3 = "";
							
						if(!bolFatalErr) 
							strTemp2 = (String)vEmpRec.elementAt(32);
						else if (!bolCleanUp) 
							strTemp2 = WI.fillTextValue("is_nonacad_jun"); 
						else
							strTemp2 = "";
						
						if(strTemp2.equals("1"))
							strTemp4 = "checked";
						else
							strTemp4 = "";
					%>					
					<input type="checkbox" name="is_nonacad_jun" value="1" <%=strTemp3%> <%=strTemp4%>>Non-Academic Junior Staff<br>
					<%
						if(!bolFatalErr) 
							strTemp2 = (String)vEmpRec.elementAt(33);
						else if (!bolCleanUp) 
							strTemp2 = WI.fillTextValue("is_nonacad_sen"); 
						else
							strTemp2 = "";
						
						if(strTemp2.equals("1"))
							strTemp4 = "checked";
						else
							strTemp4 = "";
					%>
					<input type="checkbox" name="is_nonacad_sen" value="1" <%=strTemp3%> <%=strTemp4%>>Non-Academic Senior Staff</td>
		  </tr>
		<%}}%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="20%" valign="bottom">Position</td>
            <td width="78%"> 
<% if(!bolFatalErr) strTemp2 = (String)vEmpRec.elementAt(9);
else if (!bolCleanUp) 
	strTemp2 = WI.fillTextValue("emp_type"); 
else
	strTemp2 = "";
%> 
<select name="emp_type" >
  <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
</select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewEmpTypes()'><img src="../../../images/update.gif" border="0"></a> 
              <font size="1">click to add position to list</font>
<%}%>		    </td>
          </tr>
		<%if(bolAUF && false){%>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25" valign="middle">Job Description: </td>
            <td height="30">
				<% 
					if(!bolFatalErr) 
						strTemp2 = WI.getStrValue((String)vEmpRec.elementAt(28));
					else if (!bolCleanUp) 
						strTemp2 = WI.fillTextValue("job_description"); 
					else
						strTemp2 = "";
				%> 
				<textarea name="job_description" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp2%></textarea></td>
          </tr>
		<%}%>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Employment Status </td>
            <td height="30" valign="bottom">
<% if(!bolFatalErr) 
	strTemp2 = (String)vEmpRec.elementAt(22);
else if (!bolCleanUp) 
	strTemp2 = WI.fillTextValue("pt_ft"); 
else
	strTemp2 = "";
%>
              <select name="pt_ft" >
			  <option value="1">Full Time </option>
			 <% if (strTemp2.equals("0")){%>  				
			  <option value="0" selected>Part Time </option>	
			 <%}else{%> 
			  <option value="0">Part Time </option>
			 <%}%> 
            </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Employment Tenure </td>
            <td height="25"> 
<% if (!bolFatalErr) strTemp2 = (String)vEmpRec.elementAt(10);
else if (!bolCleanUp)
 	strTemp2 = WI.fillTextValue("status");
else
	strTemp2 = "";
%> 
              <select name="status">
                <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp2, false)%> </select> 
<%if(!bolMyHome && iAccessLevel > 1){%>
				<a href='javascript:viewList("user_status","status_index","status","EMPLOYEE STATUS",
		  			"USER_TABLE,USER_TABLE,HR_INFO_EMP_HIST,HR_APPL_INFO_EMP_HIST,HR_INFO_SERVICE_RCD",
					"CURRENT_STATUS,ENTRY_STATUS,EMP_STATUS_INDEX,EMP_STATUS_INDEX,STATUS",
					" and user_table.is_del = 0 and user_table.is_valid = 1, and user_table.is_del=0 and 
					user_table.is_valid = 1, and HR_INFO_EMP_HIST.is_del =0 and HR_INFO_EMP_HIST.is_valid =1,
					and HR_APPL_INFO_EMP_HIST.is_del = 0 and HR_APPL_INFO_EMP_HIST.is_valid =1,
					and HR_INFO_SERVICE_RCD.IS_VALID=1 and HR_INFO_SERVICE_RCD.is_del = 0 ", " is_for_student = 0","status")'> 
              <img src="../../../images/update.gif" border="0"></a> <font size="1">click to add EMPLOYMENT TENURESHIP to list</font> 
<%}%>		    </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="loadDept();">
                <option value="0">N/A</option>
<% if (!bolFatalErr)  
	strTemp = (String)vEmpRec.elementAt(11);
else
	if (!bolCleanUp) {   
		strTemp = WI.fillTextValue("c_index");
	}else{
		strTemp = "";
	} 
	
	%>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select>
			<% if (!bolMyHome && iAccessLevel > 1){%>
				<% if (bolIsSchool){%>
				<a href="javascript:AddMoreCollege();"><img src="../../../images/update.gif" border="0"></a> 
              <font size="1">click to add/assign multiple </font> 
              <%}%>
						<%}%>			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Office/Department</td>
            <td height="25"> 
			 <label id="load_dept">
			 <select name="d_index">
			 
<% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
                <option value="">All</option>
<%} 
if (!bolFatalErr)  strTemp3 = (String)vEmpRec.elementAt(12);
else if (!bolCleanUp) 
	strTemp3 = WI.fillTextValue("d_index");
else
	strTemp3 = "";
	
if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	else strTemp = " and c_index = " +  strTemp;
%>
               <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp3, false)%> </select>
			  </label>
              &nbsp;
<%// if (WI.fillTextValue("c_index").length() ==0 || WI.fillTextValue("c_index").equals("0")) {%>
		<% if (bolIsSchool && !bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewListOffices("DEPARTMENT","D_INDEX","D_NAME","DEPARMENT",
				"FA_REMIT_TYPE,INFO_FACULTY_BASIC,CLE_SUB_SIGNATORY, HR_INFO_SERVICE_RCD, OSA_ORGANIZATION",
				"D_INDEX, D_INDEX, D_INDEX, D_INDEX, D_INDEX", 
				" and FA_REMIT_TYPE.is_valid = 1, and INFO_FACULTY_BASIC.is_valid = 1, " + 
				" and CLE_SUB_SIGNATORY.is_valid = 1, and HR_INFO_SERVICE_RCD.is_valid = 1, " +
				" and OSA_ORGANIZATION.is_valid = 1"," c_index is null or c_index = 0")'>
				<img src="../../../images/update.gif" border="0"></a> 
              <font size="1">click to add multiple department</font>
							<%}%>
              <%//}%>		    </td>
          </tr>
<%if(bolHasTeam){
if (!bolFatalErr)  
	strTemp3 = strTeamIndex;
else if (!bolCleanUp) 
	strTemp3 = WI.fillTextValue("team_index");
else
	strTemp3 = "";

%>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Team</td>
            <td height="25">
				<select name="team_index">
               	<%=dbOP.loadCombo("team_index","team_name"," from AC_TUN_TEAM where is_valid = 1 order by team_name",strTemp3, false)%> 
			   </select>			</td>
          </tr>
<%}%>
          <tr> 
            <td height="10" colspan="3">&nbsp;</td>
          </tr>
        </table>
        <table width="95%" border="0" cellpadding="0" cellspacing="0">
<% 

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(0));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(1));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(2));
   }else{
   		if (!bolCleanUp) {
	   		strTemp  = WI.fillTextValue("cstatus");
			strTemp2 = WI.fillTextValue("pob");
			strTemp3 = WI.fillTextValue("nationality");
	   }
	   else{
	   		strTemp=""; strTemp2 =""; strTemp3="";
	   }
   }
%>		
          <tr>
            <td height="20" colspan="4" bgcolor="#D9EDF9"><strong><font color="#CC3333">&nbsp;PERSONAL DATA</font></strong> </td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="20%" height="25">Civil Status</td>
            <td width="24%" height="25"> <select name="cstatus">
                <option value="1">Single</option>
                <% if (strTemp.compareTo("2") == 0) {%>
                <option value="2" selected>Married</option>
                <%}else{%>
                <option value="2">Married</option>
                <%} if (strTemp.compareTo("3") == 0) {%>
                <option value="3" selected>Divorced/Separated</option>
                <%}else{%>
                <option value="3" >Divorced/Separated</option>
                <%} if (strTemp.compareTo("4") == 0) {%>
                <option value="4" selected>Widow/Widower</option>
                <%}else{%>
                <option value="4" >Widow/Widower</option>
                <%}
			if(bolAUF){
				if (strTemp.compareTo("5") == 0) {%>
                <option value="5" selected>Annuled</option>
                <%}else{%>
                <option value="5" >Annuled</option>
                <%}if (strTemp.compareTo("6") == 0) {%>
                <option value="6" selected>Living Together</option>
                <%}else{%>
                <option value="6" >Living Together</option>
                <%}
			}%>
            </select></td>
            <td width="54%"><a href="javascript:viewCivilStatus();"><img src="../../../images/view.gif" width="40" height="31" border="0"></a> <font size="1">click to set changes in status</font></td>
          </tr>
                   
			<%if(bolAUF){%>
         <tr>
		  	<%
				if (!bolNoRecord)
					strTemp4 = WI.getStrValue((String)vRetResult.elementAt(25));
				else{
					if (!bolCleanUp) 
						strTemp4 = WI.fillTextValue("engagement_rites");
					else
						strTemp4 = "";
				}
			%>
            <td height="25">&nbsp;</td>
            <td>Engagement Rite: </td>
            <td colspan="2">
				<select name="engagement_rites">
					<option value="">N/A</option>
				<%if(strTemp4.equals("1")){%>
					<option value="1" selected>Civil Wedding</option>
				<%}else{%>
					<option value="1">Civil Wedding</option>
				<%}if(strTemp4.equals("2")){%>
					<option value="2" selected>Church Wedding</option>
				<%}else{%>
					<option value="2">Church Wedding</option>
				<%}if(strTemp4.equals("3")){%>
					<option value="3" selected>Military Wedding</option>
				<%}else{%>
					<option value="3">Military Wedding</option>
				<%}%>
				</select></td>
          </tr>
	<%}%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Place of Birth</td>
            <td height="25" colspan="2"><input name="pob" value="<%=strTemp2%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address222" size="48"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Nationality</td>
            <td height="25" colspan="2"><select name="nationality">
                <option value="">Select nationality</option>
                <%=dbOP.loadCombo("NATIONALITY_INDEX","NATIONALITY"," FROM HR_PRELOAD_NATIONALITY",strTemp3,false)%> </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_NATIONALITY","NATIONALITY_INDEX","NATIONALITY","NATIONALITY",
				"HR_INFO_PERSONAL,HR_APPL_INFO_PERSONAL","NATIONALITY_INDEX, NATIONALITY_INDEX", 
				" and HR_INFO_PERSONAL.is_del = 0, and HR_APPL_INFO_PERSONAL.is_del = 0","","nationality")'><img  border="0" src="../../../images/update.gif"></a> 
              <font size="1">click to add/edit list of nationality</font>
<%}%>			  </td>
          </tr>
<%
   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(3));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(4));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(5));
   }else{
   		if (!bolCleanUp){
			strTemp = WI.fillTextValue("religion");
			strTemp2 = WI.fillTextValue("sss");
			strTemp3 = WI.fillTextValue("tin");
		}else{
			strTemp = ""; strTemp2 =""; strTemp3="";
		}
		
   }
%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Religion</td>
            <td height="25" colspan="2"><select name="religion">
                <option value="">Select Religion</option>
                <%=dbOP.loadCombo("RELIGION_INDEX","RELIGION"," FROM HR_PRELOAD_RELIGION order by religion",strTemp,false)%> </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_RELIGION","RELIGION_INDEX","RELIGION","RELIGION",
				"HR_INFO_PERSONAL,HR_APPL_INFO_PERSONAL","RELIGION_INDEX, RELIGION_INDEX", 
				" and HR_INFO_PERSONAL.is_del = 0, and HR_APPL_INFO_PERSONAL.is_del = 0","","religion")'><img border="0" src="../../../images/update.gif"></a> 
              <font size="1">click to add/edit list of religion</font>
<%}%>			  </td>
          </tr>
          <tr>
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">SSS Number</td>
            <td height="25" colspan="2"><input name="sss" type= "text" value="<%=strTemp2%>" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="sss" size="16"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">TIN </td>
            <td height="25" colspan="2"><input name="tin" type= "text" class="textbox"  value="<%=strTemp3%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin" size="16"></td>
          </tr>
          <% 

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(16));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(17));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(18));
   }else{
   		if (!bolCleanUp){
			strTemp = WI.fillTextValue("philhealth");
		  strTemp2 = WI.fillTextValue("pag_ibig");
			strTemp3 = WI.fillTextValue("peraa");
		}else{
			strTemp = ""; strTemp2=""; strTemp3="";
		}
   }
%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Philhealth</td>
            <td height="25" colspan="2"><input name="philhealth" type= "text" class="textbox"  value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin2" size="16"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Pag-ibig</td>
            <td height="25" colspan="2"><input name="pag_ibig" type= "text" class="textbox"  value="<%=strTemp2%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin3" size="16"></td>
          </tr>
    <% if (bolIsSchool && !bolIsGovernment) {%> 
		      <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">PERAA</td>
            <td height="25" colspan="2"><input name="peraa" type= "text" class="textbox"  value="<%=strTemp3%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin4" size="16"></td>
          </tr>
		<%}%>
		<%if(bolIsGovernment){
				if (!bolNoRecord) 
					strTemp = WI.getStrValue((String)vRetResult.elementAt(24));
				else{
					if (!bolCleanUp)
						strTemp = WI.fillTextValue("gsis");
					else
						strTemp = "";					
				}%>		
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25">GSIS </td>
            <td height="25" colspan="2"><input name="gsis" type= "text" class="textbox"  value="<%=strTemp%>" 
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="gsis" size="16" maxlength="32"></td>
          </tr>
		<%}%>
				
   <%if (!bolCleanUp) {	
	   strTemp = WI.fillTextValue("father");
	   strTemp2 = WI.fillTextValue("f_occ");
	   strTemp3 = WI.fillTextValue("mother");
   }else{
   	strTemp =""; strTemp2 = ""; strTemp3="";
   }

   if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(7));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(8));
   }
%>
          <tr> 
            <td colspan="4"><hr size="1"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Father's Name</td>
            <td height="25" colspan="2"><input name="father" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="father" size="32"> 
              &nbsp;&nbsp;&nbsp; 
<% if (!bolNoRecord) strTemp = WI.getStrValue((String)vRetResult.elementAt(19),"1");
	strTemp2 =""; strTemp3="";
	if (strTemp.compareTo("0") == 0) strTemp3 = "checked";
	else strTemp2 = "checked";
%>
			  <input type="radio" name="f_living" value="1" onClick="ChangeState('staff_profile.f_occ',1)" <%=strTemp2%>> Living &nbsp;&nbsp; 
			  <input type="radio" name="f_living" value="0" onClick="ChangeState('staff_profile.f_occ',0)" <%=strTemp3%>> Deceased</td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Occupation</td>
<% if (!bolNoRecord) 
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(7));
	else 
		if (!bolCleanUp) 
			strTemp2 = WI.fillTextValue("f_occ");	
		else
			strTemp2 = "";
		
	if (strTemp3.length() > 0) strTemp3 = "readonly =\"yes\"";
		else strTemp3 = "";
%>
            <td height="25" colspan="2"><input name="f_occ" type= "text" value ="<%=strTemp2%>" class="textbox" size="40" <%=strTemp3%>></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Mother's Name</td>
<% if (!bolNoRecord) strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
	else
		if (!bolCleanUp){ 
			strTemp = WI.fillTextValue("mother");
		}else{
			strTemp = "";
		}%>			
            <td height="25" colspan="2"><input name="mother" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="mother" size="32"> 
              &nbsp;&nbsp;&nbsp; 
<% if (!bolNoRecord) strTemp = WI.getStrValue((String)vRetResult.elementAt(20),"1");
   else strTemp = WI.fillTextValue("m_living");
   
	strTemp2 =""; strTemp3="";
	if (strTemp.compareTo("0") == 0) strTemp3 = "checked";
	else strTemp2 = "checked";
%>	
			  <input type="radio" name="m_living" value="1" onClick="ChangeState('staff_profile.m_occ',1)" <%=strTemp2%>>Living &nbsp;&nbsp;&nbsp; 
			  <input type="radio" name="m_living" value="0" onClick="ChangeState('staff_profile.m_occ',0)" <%=strTemp3%>> 
			  Deceased</td>
          </tr>
<% 
if (!bolNoRecord) 
	strTemp = WI.getStrValue((String)vRetResult.elementAt(9));
else if (!bolCleanUp) 
	strTemp = WI.fillTextValue("m_occ");
 else
 	strTemp = "";

if (strTemp3.length() > 0) strTemp3 = "readonly =\"yes\"";
	else strTemp3 = "";
%>        <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Occupation</td>
            <td height="25" colspan="2"><input name="m_occ" <%=strTemp3%> type= "text" value="<%=strTemp%>" class="textbox" size="40"></td>
          </tr>
          <tr> 
            <td height="10" colspan="4"><hr size="1"></td>
          </tr>
<% if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(10));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(11));
   }else{
		if (!bolCleanUp){
		  strTemp = WI.fillTextValue("height");
		  strTemp2 = WI.fillTextValue("weight");
		}else{
		  strTemp = ""; strTemp2="";
		}
   }
%>      <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Height (in cms)</td>
            <td height="25" colspan="2"><input name="height" type= "text" value="<%=strTemp%>" onKeypress=" AllowOnlyFloat('staff_profile','height')" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="height" size="8"> 
              <font size="1">(1ft = 30.48cms)</font> <a href="javascript:Convert();">CLICK 
              FOR CONVERSION</a></td>
        </tr>
        <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Weight (in lbs)</td>
            <td height="25" colspan="2"><input name="weight" type= "text" value="<%=strTemp2%>" onKeypress=" AllowOnlyFloat('staff_profile','weight')" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="weight" size="8"> 
              <font size="1">(1kg = 2.2lbs)</font></td>
        </tr>
<% if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(12));
		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(13));
		strTemp3 = WI.getStrValue((String)vRetResult.elementAt(22));
   }else{
   		if (!bolCleanUp){
		  strTemp = WI.fillTextValue("blood");
		  strTemp2 = WI.fillTextValue("rh");
		  strTemp3 = WI.fillTextValue("dis_marks");
		}else{
			strTemp =""; strTemp2 =""; strTemp3="";
		}
   }
%>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Blood Type</td>
            <td height="25" colspan="2"><select name="blood">
                <option value="">Not Known</option>
                <% if (strTemp.equals("1")) {%>
                <option value="1" selected>A</option>
                <%}else{%>
                <option value="1" >A</option>
                <%}if (strTemp.equals("2")) {%>
                <option value="2" selected >B</option>
                <%}else{%>
                <option value="2" >B</option>
                <%}if (strTemp.equals("3")) {%>
                <option value="3" selected >AB</option>
                <%}else{%>
                <option value="3" >AB</option>
                <%}if (strTemp.equals("4")) {%>
                <option value="4" selected>O</option>
                <%}else{%>
                <option value="4" >O</option>
                <%}%>
              </select> <select name="rh" >
                <option value="0">+</option>
                <% if (strTemp2.equals("1")){%>
                <option value="1" selected>-</option>
                <%}else{%>
                <option value="1">-</option>
                <%}%>
              </select> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Distinguishing Marks</td>
            <td height="25" colspan="2"><input name="dis_marks" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp3%>"   size="40" maxlength="64"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Remarks</td>
<% if (!bolNoRecord){
   		strTemp = WI.getStrValue((String)vRetResult.elementAt(26));
   }else{
		if (!bolCleanUp){
		  strTemp = WI.fillTextValue("remarks");
		}else{
		  strTemp = ""; 
		}
   }
%>  
            <td height="25" colspan="2">
						<textarea name="remarks" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td colspan="3">
                <% if (iAccessLevel > 1){%>
              <div align="center"> <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a> 
                <font size="1">click to save entries</font> 
<% if (false && vEmpRec != null && vEmpRec.size() > 0 && vRetResult != null && vRetResult.size() > 0) { %>
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> <font size="1">click to print profile</font>
<%}%>
			  </div>
              <%}%>&nbsp;</td>
          </tr>
        </table>
      </td>
</tr>
</table>

<%
} // if (WI.getStrValue(strTemp).lenght() == 0)

   if (vEmpRec != null && vEmpRec.size() > 0){
   		strInfoIndex = WI.getStrValue((String)vEmpRec.elementAt(0));
   }
%>  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="reloadPage"> 
<input type="hidden" name="page_action">
<input type="hidden" name="showDB" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="print_page" value="0">
<input type="hidden" name="curr_emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="uncheck_is_valid" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
