<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRInfoEducation" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request); 

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
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function viewInfo(){
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.page_action.value = "3";
	this.SubmitOnce("staff_profile");	
}
function viewDetail(index){
	var loadPg = "./hr_personnel_educ_detail.jsp?info_index="+index+
	"&my_home="+document.staff_profile.my_home.value+
	"&applicant_=" +document.staff_profile.applicant_.value ;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}
function viewEducLevels()
{
	var loadPg = "./hr_educ_levels.jsp";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewSchoolList(){
	var loadPg = "../hr_updateschlist.jsp";
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function ReloadPage(){
	document.staff_profile.reloadPage.value = "1";
	this.SubmitOnce("staff_profile");
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.reloadPage.value = "1";
	this.SubmitOnce("staff_profile");
}

function CancelRecord(index){
	location = "./hr_personnel_education.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+index+
	"&my_home=<%=WI.fillTextValue("my_home")%>";
}
function FocusID() {
<% if (WI.fillTextValue("my_home").compareTo("1") !=0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage(){

	document.staff_profile.print_page.value="1";
	document.staff_profile.submit();
	
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
	document.staff_profile.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%
	if (request.getParameter("print_page") != null && 
			request.getParameter("print_page").equals("1")){ %>
			<jsp:forward page="./hr_personnel_education_print.jsp" />
<% return;}

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").compareTo("1") ==0)
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
		
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

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
int iAccessLevel = -1;
if(WI.fillTextValue("applicant_").equals("1") ) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(),
															"hr_personnel_education.jsp");
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_education.jsp");
}											
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
Vector vEditResult = null;
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = WI.fillTextValue("info_index");

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strReloadPage = WI.getStrValue(request.getParameter("reloadpage"),"0");

HRManageList hrList = new HRManageList();
HRInfoEducation hrEduc = new HRInfoEducation();
//HRUpdateTables hrUpdate = new HRUpdateTables();

//hrUpdate.updateEducationTable(dbOP);

hr.HRInfoEducationExtn test = new hr.HRInfoEducationExtn();
test.getFacultyEducQualification(dbOP, request);

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){
	
	if(bolIsApplicant){
		hr.HRApplNew hrApplNew = new hr.HRApplNew();
		vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	}else{	
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() ==0)
			strErrMsg = authentication.getErrMsg();
	}
	if (vEmpRec != null && vEmpRec.size() > 0)	{
		bNoError = true;
	}else{		
		bNoError = false;
	}

	if (bNoError) {
		if( iAction == 0 || iAction  == 1 || iAction == 2)
		vRetResult = hrEduc.operateOnEducation(dbOP,request,iAction);


		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null){
					strPrepareToEdit = "";
					if(bolIsApplicant)
						strErrMsg = " Applicant education record removed successfully.";
					else	
						strErrMsg = " Employee education record removed successfully.";
				}
				else
					strErrMsg = hrEduc.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant education record added successfully.";
					else
						strErrMsg = " Employee education record added successfully.";
				}
				else
					strErrMsg = hrEduc.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant education record edited successfully.";
					else	
						strErrMsg = " Employee education record edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrEduc.getErrMsg();
				break;
			}
		}
	}
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditResult = hrEduc.operateOnEducation(dbOP,request,3);

	if (vEditResult != null && vEditResult.size() > 0) 	
		bSetEdit = true;

	if (WI.fillTextValue("setEdit").equals("1"))  
		bSetEdit = false;

}

vRetResult = hrEduc.operateOnEducation(dbOP,request, 4);
if (vRetResult == null) strErrMsg = hrEduc.getErrMsg();

boolean bolAllowUpdate = false;
if(strSchCode.startsWith("CIT"))
	bolAllowUpdate = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_education.jsp" method="post" name="staff_profile">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" align="center">
      <td height="25" colspan="6" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        EDUCATIONAL RECORDS PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<font size=3><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="38%" height="25">&nbsp;&nbsp;
	  <%if(bolIsApplicant){%>
	  Applicant ID : <%}else{%>
	  Employee ID : <%}%><input name="emp_id" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      </td>
      <td width="7%" height="25">	  <%if(!bolIsApplicant){%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
	  <%}%></td>
	<td width="55%"><a href="javascript:viewInfo();"><img src="../../../images/form_proceed.gif" border="0"></a><label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong> 
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>

  </table>
<% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td colspan="2"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
<% if (!WI.fillTextValue("applicant_").equals("1")) {%>
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
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br>
			<% if (!bolIsApplicant) {%>
			  <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
			 <%}%>
            </td>
          </tr>
        </table>
<%}else{%>
        <table width="400" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.getStrValue(WI.fillTextValue("emp_id"),strTemp).toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vEmpRec.elementAt(1),
			  								(String)vEmpRec.elementAt(2),
						 				    (String)vEmpRec.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vEmpRec.elementAt(11))%><br> 
              <%=WI.getStrValue(vEmpRec.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vEmpRec.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table>
<%}%>
        <br>
<table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="1%" rowspan="17">&nbsp;</td>
            <td width="20%" height="25">Education</td>
            <td width="79%" height="25"> <select name="educ_type" id="educ_type">
                <option value="">Select Educ. Type</option>
                <%	strTemp = WI.fillTextValue("educ_type");
	strTemp2 = WI.fillTextValue("sch_index");
	if (bSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(0);
		strTemp2 = (String)vEditResult.elementAt(1);
	}
%>
                <%=dbOP.loadCombo("EDU_TYPE_INDEX","EDU_NAME",",ORDER_NO FROM HR_PRELOAD_EDU_TYPE ORDER BY ORDER_NO",strTemp,false)%> </select> <strong> 
			<% if (!bolMyHome && iAccessLevel > 1) {%>
				<a href='javascript:viewEducLevels();'><img src="../../../images/update.gif" border="0"></a> 
              </strong><font size="1">click to add educational level</font>
			<%}%>			  </td>
          </tr>
          <tr> 
            <td height="25">Name of School</td>
            <td height="25"><select name="sch_index" onChange="ReloadPage();">
                <option value="">Select School </option>
                <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," FROM HR_PRELOAD_SCHOOL order by sch_name",strTemp2,false)%> </select>  
<%if((!bolMyHome || bolAllowUpdate)  && iAccessLevel > 1){%>
				<a href='javascript:viewSchoolList();'> 
              	<img src="../../../images/update.gif" border="0"></a> <font size="1">click to add school</font>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="25">School Address</td>
            <%
 // output the school address
	strTemp2 = hrList.getSchoolAddress(dbOP,strTemp2);
%>
            <td height="25"><strong><%=WI.getStrValue(strTemp2)%>&nbsp;</strong></td>
          </tr>
          <tr> 
            <td height="25">Degree Earned<font color="#FF0000">*</font></td>
            <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp = (String)vEditResult.elementAt(2); //
 }else{
	strTemp = WI.fillTextValue("degree");
}%>
            <td height="25"><input name="degree" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="64" value ="<%=WI.getStrValue(strTemp)%>">            </td>
          </tr>
          <tr>
            <td height="25"><div align="right">Major &nbsp;&nbsp;</div></td>
            <%if (bSetEdit && strPrepareToEdit.equals("1")) {
				strTemp = (String)vEditResult.elementAt(25); //
			 }else{
				strTemp = WI.fillTextValue("major_name");
			}%>			
            <td height="25"><font size="1"><strong>
              <input name="major_name" type= "text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value ="<%=WI.getStrValue(strTemp)%>"  size="32" maxlength="32">
              </strong></font></td>
          </tr>
          <tr> 
            <td height="25"><div align="right">Minor &nbsp;&nbsp;</div></td>
            <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
				strTemp = (String)vEditResult.elementAt(26); //
			 }else{
				strTemp = WI.fillTextValue("minor_name");
			}%>
            <td height="25"><font size="1"><strong>
              <input name="minor_name" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value ="<%=WI.getStrValue(strTemp)%>"  size="32" maxlength="32">
              </strong></font></td>
          </tr>
          <tr> 
            <td height="25">Date Graduated<font color="#FF0000">*</font></td>
            <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = WI.getStrValue((String)vEditResult.elementAt(3)); //
	strTemp2 = WI.getStrValue((String)vEditResult.elementAt(14)); //
	strTemp3 = WI.getStrValue((String)vEditResult.elementAt(15)); //
  }else{
  strTemp = WI.fillTextValue("grad_month");
  strTemp2 = WI.fillTextValue("grad_day");
  strTemp3 = WI.fillTextValue("grad_year");    
}%>
            <td height="25"> <input name="grad_month" type="text" size="2" maxlength="2" class="textbox" 
			  onKeyUp="AllowOnlyInteger('staff_profile','grad_month')"  value="<%=strTemp%>"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              / 
              <input name="grad_day" type="text" size="2" maxlength="2" class="textbox" 
			  onKeyUp="AllowOnlyInteger('staff_profile','grad_day')"    value="<%=WI.getStrValue(strTemp2)%>"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              / 
              <input name="grad_year" type="text" size="4" maxlength="4" class="textbox" 
			  onKeyUp="AllowOnlyInteger('staff_profile','grad_year')"   value="<%=strTemp3%>"
			   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
              <font size="1">(mm/dd/yyyy)</font></td>
          </tr>
          <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = (String)vEditResult.elementAt(4); //
	strTemp2 = (String)vEditResult.elementAt(5);
 }else{
	strTemp = WI.fillTextValue("units");
	strTemp2 = WI.fillTextValue("thesis");
 }
%>
          <tr>
            <td height="25">No. of Units Completed<font color="#FF0000">*</font></td>
            <td height="25"><input name="units" type= "text" value = "<%=WI.getStrValue(strTemp)%>" class="textbox" 
			  onKeyUp="AllowOnlyFloat('staff_profile','units')" size="5" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
              &nbsp;<font color="#FF0000">&nbsp;<font color="#0000FF" size="1">(encode only if degree is on going)</font></font> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">
<% if (bSetEdit && strPrepareToEdit.equals("1")) 
	strTemp = (String)vEditResult.elementAt(27);
   else 
   	strTemp = WI.fillTextValue("car");
	if (strTemp.equals("1"))
		strTemp ="checked";
	else
		strTemp = "";
%>	
              <input name="car" type="checkbox" value="1" <%=strTemp%>>
              <font size="1">check if completed academic requirements</font></td>
          </tr>
          <tr> 
            <td height="25">Dissertation/Thesis<font color="#FF0000">*</font></td>
            <td height="25"> <input name="thesis" type="text" class="textbox" id="thesis" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp2)%>" size="64"> 
              <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = WI.getStrValue((String)vEditResult.elementAt(6)); //
	strTemp2 = (String)vEditResult.elementAt(7);
}else{
	strTemp = WI.fillTextValue("published");
	strTemp2 = WI.fillTextValue("gwa");
}
if (strTemp.compareTo("1")== 0) strTemp = "checked";
else strTemp ="";%> <br> <input name="published" type="checkbox" value="1" <%=strTemp%>>
              Published</td>
          </tr>
<% if (!strSchCode.startsWith("CPU")) {%>
          <tr> 
            <td height="25">General Weighted<font color="#FF0000">*</font><br>
            Average </td>
            <td height="25"><input name="gwa" type= "text" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyFloat('staff_profile','gwa')" size="5"></td>
          </tr>
<%}%>
		  
          <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = WI.getStrValue((String)vEditResult.elementAt(8)); //
	strTemp2 = WI.getStrValue((String)vEditResult.elementAt(16));
	strTemp3 = WI.getStrValue((String)vEditResult.elementAt(17));
}else{
	strTemp  = WI.fillTextValue("mdate_from");
	strTemp2 = WI.fillTextValue("ddate_from");
	strTemp3 = WI.fillTextValue("ydate_from");
}%>
          <tr> 
            <td rowspan="2"> Date of Attendance</td>
            <td height="25">From : 
              <input name="mdate_from" type="text" size="2" maxlength="2" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','mdate_from')" value="<%=strTemp%>">
              / 
              <input name="ddate_from" type="text" size="2" maxlength="2" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','ddate_from')"  value="<%=strTemp2%>">
              / 
              <input name="ydate_from" type="text" size="4" maxlength="4" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','ydate_from')"  value="<%=strTemp3%>"> 
              <font size="1"> (mm/dd/yyyy)</font> </td>
          </tr>
          <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = WI.getStrValue((String)vEditResult.elementAt(9)); //
	strTemp2 = WI.getStrValue((String)vEditResult.elementAt(18));
	strTemp3 = WI.getStrValue((String)vEditResult.elementAt(19));
}else{
	strTemp  = WI.fillTextValue("mdate_to");
	strTemp2 = WI.fillTextValue("ddate_to");
	strTemp3 = WI.fillTextValue("ydate_to");
}%>
          <tr> 
            <td height="25">To:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <input name="mdate_to" type="text" size="2" maxlength="2"  class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','mdate_to')" value="<%=strTemp%>">
              / 
              <input name="ddate_to" type="text" size="2" maxlength="2" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','ddate_to')" value="<%=strTemp2%>">
              / 
              <input name="ydate_to" type="text" size="4" maxlength="4"  class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
 		    onKeyUp="AllowOnlyInteger('staff_profile','ydate_to')" value="<%=strTemp3%>"> 
              <font size="1"> (mm/dd/yyyy)</font></td>
          </tr>
          <tr> 
            <%if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) {
	strTemp  = (String)vEditResult.elementAt(10); //
	strTemp2 = (String)vEditResult.elementAt(11);
}else{
	strTemp = WI.fillTextValue("honor_type");
	strTemp2 = WI.fillTextValue("awards");
}
%>
            <td height="25">Graduation Honors</td>
            <td height="25"><select name="honor_type" id="select">
                <option value="">Select Honors Received</option>
                <%=dbOP.loadCombo("GRAD_HONOR_INDEX","HONOR_NAME"," FROM HR_PRELOAD_HONOR_TYPE order by honor_name",strTemp,false)%> </select> 
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
				<a href='javascript:viewList("HR_PRELOAD_HONOR_TYPE","GRAD_HONOR_INDEX","HONOR_NAME","HONOR TYPE",
				"HR_APPL_INFO_EDU_HIST,HR_INFO_EDU_HIST","GRAD_HONOR_INDEX, GRAD_HONOR_INDEX", 
				" and HR_APPL_INFO_EDU_HIST.is_del = 0, and HR_INFO_EDU_HIST.is_del = 0","","honor_type");'><img src="../../../images/update.gif" border="0"></a> 
              <font size="1">click to add type of honors</font>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="25" colspan="2">Awards:<br> <textarea name="awards" cols="50" rows="2" id="awards" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp2)%></textarea>            </td>
          </tr>
          <% if (bSetEdit && strPrepareToEdit.compareTo("1") == 0) strTemp  = (String)vEditResult.elementAt(12);
 else strTemp = WI.fillTextValue("remarks"); %>
          <tr> 
            <td height="25" colspan="2"> Remarks:<br> <textarea name="remarks" cols="50" rows="2" id="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>            </td>
          </tr>
          <tr> 
            <td height="25" colspan="2" align="right">LEGEND : <font color="#FF0000">*</font> 
              -<font size="1"> If applicable</font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td height="25" colspan="2"> <div align="center"> 
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{ %>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
                to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> 
                <%}}%>
              </div></td>
          </tr>
        </table>

      </td>
 </tr>
</table>
<%	if (vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#EAF5D8">
    <td height="25" colspan="5" align="center" class="thinborder"><strong><font color="#333333">LIST 
      OF EDUCATIONAL RECORD</font></strong></td>
  </tr>
  <tr align="center">
    <td width="15%" height="20" class="thinborder"><font size="1"><strong>EDUCATION</strong></font></td>
    <td width="28%" class="thinborder"><font size="1"><strong>SCHOOL</strong></font></td>
    <td width="23%" class="thinborder"><font size="1"><strong>DEGREE</strong></font></td>
    <td width="13%" class="thinborder"><font size="1"><strong>HONORS</strong></font></td>
    <td width="22%" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
  </tr>
  <% 	for (int i = 0; i < vRetResult.size(); i +=28) {%>
  <tr>
    <td class="thinborder"><font size="1"><strong><%=(String)vRetResult.elementAt(i+21)%><br>
      </strong> Fr :<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"--") + "/"    + 
	  	 WI.getStrValue((String)vRetResult.elementAt(i+16),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+17),"--")%> <br>
      To : <%=WI.getStrValue((String)vRetResult.elementAt(i+9),"--") + "/" +
	  	 WI.getStrValue((String)vRetResult.elementAt(i+18),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+19),"--")%> </font> </td>
    <td class="thinborder"><font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp")%><br>
      </strong> <%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp")%> <br>
      Date Graduated : <%=WI.getStrValue((String)vRetResult.elementAt(i+3),"--") + "/" +
	  	 WI.getStrValue((String)vRetResult.elementAt(i+14),"--") + "/" +
		 WI.getStrValue((String)vRetResult.elementAt(i+15),"--")%> </font></td>
    <td class="thinborder"><% if ( WI.getStrValue((String)vRetResult.elementAt(i+27),"1").equals("1")) {%>
      (CAR)
      <%}%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+25),"(Major in ",")","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+26),"(Minor in ",")","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"<br> Units : <strong>","</strong>","")%> </td>
    <%
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+24));

	if (strTemp.length() == 0) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+11),
								"Awards: ","","&nbsp;");
	else
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+11),
								"<br>Awards: ","","");
%>
    <td class="thinborder"><font size="1"> <%=WI.getStrValue(strTemp,"&nbsp")%> </font></td>
    <td class="thinborder"><a href="javascript:viewDetail('<%=(String)vRetResult.elementAt(i+13)%>')"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
        <% if (iAccessLevel > 1){ %>
        <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i+13)%>)"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
        <% if (iAccessLevel == 2){ %>
        <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+13)%>')"><img src="../../../images/delete.gif" border="0"></a>
        <%}}%>
      &nbsp;</td>
  </tr>
  <% }// end for loop %>
</table>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#FFFFFF">
    <td height="25" colspan="5" align="center" >
		<a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>
		<font size="1"> click to print page </font>
	</td>
  </tr>
</table>
<%} // end vRetResult != null
} // end vEmpRec != null
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage" value="<%=strReloadPage%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="setEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page" value="0">

<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
