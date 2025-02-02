<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPrevEmployment"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").compareTo("1") ==0)
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
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

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function viewInfo(){
	this.SubmitOnce("staff_profile");	
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function CancelRecord(index)
{
	location = "./hr_personnel_employment.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+index+"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewDetail(strInfoIndex){
	var loadPg = "./hr_personnel_emp_detail.jsp?info_index="+strInfoIndex+"&my_home=<%=WI.fillTextValue("my_home")%>";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
	<%if(bolIsApplicant || bolMyHome){%>
		return;
	<%}%>
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
	
	document.staff_profile.page_action.value="";
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
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Previous Employment","hr_personnel_employment.jsp");

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
															"hr_personnel_employment.jsp");
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_employment.jsp");
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

Vector vEmpRec = null;
Vector vRetResult = null;
Vector vEditInfo = null;
boolean bNoError  = false;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoPrevEmployment hrCon = new HRInfoPrevEmployment();

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
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnPrevEmployment(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant previous employment record removed successfully.";
					else
						strErrMsg = " Employee previous employment record removed successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant previous employment record added successfully.";
					else
						strErrMsg = " Employee previous employment record added successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant previous employment record edited successfully.";
					else	
						strErrMsg = " Employee previous employment record edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = hrCon.operateOnPrevEmployment(dbOP,request,3);
	bNoError = false;
	if (vEditInfo != null && vEditInfo.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}

vRetResult = hrCon.operateOnPrevEmployment(dbOP,request,4);
if (vRetResult == null || vRetResult.size() == 0){
	if (strErrMsg == null)
		strErrMsg  = hrCon.getErrMsg();
}
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_employment.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          PREVIOUS EMPLOYMENT RECORD ::::</strong></font></div></td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="38%" height="25">&nbsp;&nbsp;
	  <%if(bolIsApplicant){%>
	  Applicant ID : <%}else{%>
	  Employee ID : <%}%><input name="emp_id" type= "text" class="textbox"  value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      </td>
      <td width="7%" height="25">	  <%if(!bolIsApplicant){%>
	  <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>
	  <%}%></td>
	<td width="55%"><a href="javascript:viewInfo();"><img src="../../../images/form_proceed.gif" border="0"></a>
	<label id="coa_info"></label>
	</td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong> 
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>

  </table>
<% 	if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
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
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.getStrValue(WI.fillTextValue("emp_id"), strTemp).toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
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
<%
	if (vEditInfo != null){
		strTemp =  (String) vEditInfo.elementAt(0);
		strTemp2 = (String) vEditInfo.elementAt(1);
		strTemp3 = (String) vEditInfo.elementAt(2);
	}else{
		strTemp = WI.fillTextValue("compname");
		strTemp2 = WI.fillTextValue("caddress");
		strTemp3 = WI.fillTextValue("phoneno");
	}
%>
	<table width="92%" border="0" align="center">
          <tr> 
            <td width="84">&nbsp;</td>
            <td>Company Name</td>
            <td><input name="compname" type= "text"  value="<%=WI.getStrValue(strTemp)%>"class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="compname" size="32"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Address</td>
            <td><input name="caddress" type= "text" value="<%=WI.getStrValue(strTemp2)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="caddress" size="64"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Phone Number</td>
            <td><input name="phoneno" type= "text" value="<%=WI.getStrValue(strTemp3)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="phoneno" size="24"></td>
          </tr>
          <%
	if (vEditInfo != null){
		strTemp = (String) vEditInfo.elementAt(3);
		strTemp3 = (String) vEditInfo.elementAt(5);
		if (strTemp3 != null && strTemp3.length() > 0)  
			strTemp3 = ConversionTable.replaceString(strTemp3,",","");
	}else{
		strTemp = WI.fillTextValue("position");
		strTemp3 = WI.fillTextValue("salary");
	}
	
%>
          <tr> 
            <td>&nbsp;</td>
            <td>Position</td>
            <td><input name="position" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="position" size="32">
		<% if (vEditInfo != null) 
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
			else
				strTemp = WI.fillTextValue("is_admin");
			
			if (strTemp.equals("1")) 
				strTemp = "checked";
			else
				strTemp = "";
		 %>	
			
              <input name="is_admin" type="checkbox" id="is_admin" value="1" <%=strTemp%>>
              <font size="1">check if position is administrative</font></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Employment Status</td>
            <td> <select name="status">
                <option value="">Select Status</option>
                <% if (vEditInfo != null) strTemp2 =(String)vEditInfo.elementAt(12);
				else strTemp2 = WI.fillTextValue("status");	%>
				
                <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp2, false)%> 
              </select> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td width="216">Office/Department</td>
            <td width="574">                
    <%	if (vEditInfo != null)	strTemp = (String) vEditInfo.elementAt(4);
	else strTemp = WI.fillTextValue("dept"); %>
                <input name="dept" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="dept" size="32">                </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Salary</td>
            <td><input name="salary" type= "text" value="<%=WI.getStrValue(strTemp3)%>" onKeyUp="AllowOnlyFloat('staff_profile','salary');"
			 class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('staff_profile','salary');style.backgroundColor='white'" size="16"></td>
	     </tr>
<%	if (vEditInfo != null){
		strTemp = (String) vEditInfo.elementAt(6);
		strTemp2 = (String) vEditInfo.elementAt(7);
		strTemp3 = (String) vEditInfo.elementAt(9);
	}else{
		strTemp = WI.fillTextValue("doe");
		strTemp2 = WI.fillTextValue("dol");
		strTemp3 = WI.fillTextValue("responsibility");
	}
%>
          <tr> 
            <td>&nbsp;</td>
            <td>Date of Employment</td>
            <td><input name="doe" type= "text" class="textbox"  onKeyUp="AllowOnlyIntegerExtn('staff_profile','doe','/-')" onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('staff_profile','doe','/-');style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="20" maxlength="24">
              <a href="javascript:show_calendar('staff_profile.doe');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <tr> 
            <td width="84" height="26">&nbsp;</td>
            <td>Date of Separation </td>
            <td><input name="dol" type= "text" class="textbox" onKeyUp="AllowOnlyIntegerExtn('staff_profile','dol','/-')" onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyIntegerExtn('staff_profile','dol','/-');style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp2)%>" size="20" maxlength="24">
              <a href="javascript:show_calendar('staff_profile.dol');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
<%if(!bolIsApplicant){%>
          <tr>
            <td height="26">&nbsp;</td>
            <td>Probationary Period </td>
            <td>
<%	
if (vEditInfo != null)	
	strTemp = (String) vEditInfo.elementAt(14);
else 
	strTemp = WI.fillTextValue("probationary_date"); 
%>
				<input name="probationary_date" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48">
		    </td>
          </tr>
          <tr>
            <td height="26">&nbsp;</td>
            <td>Regular Period </td>
            <td>
<%	
if (vEditInfo != null)	
	strTemp = (String) vEditInfo.elementAt(15);
else 
	strTemp = WI.fillTextValue("regular_date"); 
%>
			<input name="regular_date" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48">
			</td>
          </tr>
<%}%>		  
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><br>
              Responsibility/Assignment<br> <textarea name="responsibility" cols="50" rows="2" id="responsibility" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp3)%></textarea>            </td>
          </tr>
<%	if (vEditInfo != null){
		strTemp = (String) vEditInfo.elementAt(8);
		strTemp2 = (String) vEditInfo.elementAt(10);
	}else{
		strTemp = WI.fillTextValue("awards");
		strTemp2 = WI.fillTextValue("rol");
	}%>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><br>
              Achievement/Awards<br> <textarea name="awards" cols="50" rows="2" id="awards" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><br>
              Reason for Leaving<br> <textarea name="rol" cols="50" rows="2" id="rol" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp2)%></textarea>            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"> <div align="center"><br>
                <% if (iAccessLevel > 1){
					if (vEditInfo == null){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" ></a> 
                <font size="1">click to save entries</font> 
                <%}else{ %>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> 
                <%}}%>
              </div></td>
          </tr>
        </table>
        <br>
<%   if (vRetResult != null && vRetResult.size() > 0) { %>
        <table width="98%" border="0" align="center" cellpadding="5" cellspacing="1" bgcolor="#000000">
          <tr bgcolor="#666666">
            <td colspan="4"><div align="center"><font color="#FFFFFF"><strong>LIST
                OF PREVIOUS EMPLOYERS</strong></font></div></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="27%" > <div align="center"><font size="1"><strong>Employer
                / Address</strong></font></div></td>
            <td width="27%"><div align="center"><font size="1"><strong>Position
                / Office / Department</strong></font></div></td>
            <td width="23%"><div align="center"><font size="1"><strong>Inclusive
                Dates</strong></font></div></td>
            <td width="23%">&nbsp;</td>
          </tr>
<% for (int i = 0; i < vRetResult.size() ; i+=16) { %>
          <tr bgcolor="#FFFFFF">
            <td><p><font color="#0000FF" size="1"><strong> <%=WI.getStrValue((String)vRetResult.elementAt(i),"&nbsp;")%></strong></font><font size="1"><br>
                <%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%><br>
                <%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%> </font></p></td>
            <td><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%><br>
                <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></font></div></td>
            <td><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;") + WI.getStrValue((String)vRetResult.elementAt(i+7)," - ","","&nbsp;")%></font></div></td>
            <td> <a href="javascript:viewDetail(<%=(String)vRetResult.elementAt(i+11)%>)"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
<% if (iAccessLevel > 1) {%>
              <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i+11)%>)"><img src="../../../images/edit.gif" border="0"></a> 
              <% if (iAccessLevel == 2) {%>
            <a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i+11)%>)"><img src="../../../images/delete.gif" border="0"></a>
<%}}%>
            </td>
          </tr>
	<%} // end for loop %>
        </table>
<% }  // vRetResult !=null %>
	  </td>
    </tr>
  </table>
<% } // if (vEmpRec !=null && vEmpRec.size() > 0 %>
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
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>

