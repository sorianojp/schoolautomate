<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	
	if (WI.fillTextValue("print_page").equals("1")) { %> 
	<jsp:forward page="./hr_personnel_trainings_print.jsp" />
<% return;}
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.


boolean bolIsEAC = strSchCode.startsWith("EAC");
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
	document.staff_profile.print_page.value="0";
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	if (document.staff_profile.training_name) 
		document.staff_profile.training_name.value="";
	this.SubmitOnce("staff_profile");
}

function viewInfo(){
	document.staff_profile.print_page.value="0";
	document.staff_profile.page_action.value = "4";
	this.SubmitOnce("staff_profile");
}

function viewDetail(strInfoIndex){
	var pgLoc = "./hr_personnel_training_detail.jsp?opner_info=staff_profile.emp_id&info_index="+strInfoIndex +
	"&my_home=<%=WI.fillTextValue("my_home")%>";
	if(document.staff_profile.applicant_.value == '1')
		pgLoc += "&applicant_=1";
		
	var win=window.open(pgLoc,"detailwindow",'dependent=yes,width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.staff_profile.print_page.value="0";
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.print_page.value="0";
	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.print_page.value="0";
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");	
}

function CancelRecord(index)
{
	location = "./hr_personnel_trainings.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+escape(index)+
	"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField, strMaxLen, strHideDel){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField+"&max_len="+strMaxLen;
	if(strHideDel && strHideDel.length > 0) 
		loadPg += "&hide_del="+strHideDel;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
<% if(WI.fillTextValue("my_home").compareTo("1") != 0){%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CopyName(){
	if (document.staff_profile.training.selectedIndex != 0) 
		document.staff_profile.training_name.value= 
			document.staff_profile.training[document.staff_profile.training.selectedIndex].text;
	else
		document.staff_profile.training_name.value= "";
}

function PrintPg(){
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
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Traning","hr_personnel_trainings.jsp");

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
															"hr_personnel_trainings.jsp");
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_trainings.jsp");
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

boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining(dbOP);

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

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
		vRetResult = hrCon.operateOnTraining(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant training record removed successfully.";
					else
						strErrMsg = " Employee training record removed successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant training record added successfully.";
					else	
						strErrMsg = " Employee training record added successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant training record edited successfully.";
					else	
						strErrMsg = " Employee training record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = hrCon.operateOnTraining(dbOP,request,3);

	bNoError = false;

	if (vEditInfo != null && vEditInfo.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}

vRetResult = hrCon.operateOnTraining(dbOP,request,4);

if (vRetResult == null && strErrMsg == null ){
	strErrMsg = hrCon.getErrMsg();
}

String[] astrSemimarType={"N/A","Official Time","Official Business","Representative/Proxy",""};

boolean bolAllowUpdate = false;
if(strSchCode.startsWith("CIT"))
	bolAllowUpdate = true;
if(strSchCode.startsWith("EAC"))
	bolAllowUpdate = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          TRAININGS/SEMINARS PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
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
<%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="105%"><hr size="1">
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
		  <% if (!strSchCode.startsWith("UI") && 
			  		!strSchCode.startsWith("AUF")) {%>
          <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
		  <%} // do not show length of service%> </font> 
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
	strTemp = WI.fillTextValue("isInternal");
	strTemp2 = WI.fillTextValue("training");
	strTemp3 = WI.fillTextValue("venue");
	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vEditInfo.elementAt(2);
		strTemp2 = (String) vEditInfo.elementAt(0);
		strTemp3 = (String) vEditInfo.elementAt(3);
	}
%>
        <br>
        <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="2%" rowspan="14">&nbsp;</td>
            <td height="25" colspan="2">Name of Seminar/Training </td>
          </tr>
          <tr> 
            <td height="25" colspan="2" valign="bottom">
<% if (!strSchCode.startsWith("AUF")) {
int iMaxLen = 255;
if(strSchCode.startsWith("VMUF"))
	iMaxLen = 100;
%>
			<input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('staff_profile.starts_with2','staff_profile.training',true);">
              &nbsp;<strong>
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
			  <a href='javascript:viewList("HR_PRELOAD_TRAINING_NAME","TRAINING_NAME_INDEX","TRAINING_NAME","TRAINING NAME",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","TRAINING_NAME_INDEX, TRAINING_NAME_INDEX", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_APPL_INFO_TRAINING.is_del = 0","","training","<%=iMaxLen%>")'><img src="../../../images/update.gif" border="0"></a></strong><font size="1">click to add to list of NAME OF SEMINAR/TRAINING</font>
<%}%>

<%}else{%> 

		<textarea name="training_name" cols="64" rows="4" class="textbox" style="font-size:12px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("training_name")%></textarea>
<%}%>		    </td>
          </tr>
          <tr> 
            <td height="25" colspan="2" valign="top"><strong>
              <select name="training"
<% if (strSchCode.startsWith("AUF")) {%>
	onChange="CopyName()"
<%}%> 
			  >
                <option value="">Select Training/Seminar</option>
                <%=dbOP.loadCombo("TRAINING_NAME_INDEX","TRAINING_NAME"," FROM HR_PRELOAD_TRAINING_NAME order by training_name",strTemp2,false)%> 
              </select>
              <a href='javascript:viewList("HR_PRELOAD_TRAINING_NAME","TRAINING_NAME_INDEX","TRAINING_NAME","TRAINING NAME",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","TRAINING_NAME_INDEX, TRAINING_NAME_INDEX", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_APPL_INFO_TRAINING.is_del = 0","","training")'>              </a></strong></td>
          </tr>
          <tr> 
            <td height="25">Category </td>
            <td height="25"> <select name="isInternal" >
<%
	if(bolIsSchool){
		if (strSchCode.startsWith("CPU")) 
			strTemp2 = "Internal (Conducted by the University)";
		else
			strTemp2 = "Internal (Held inside the school campus)";
	}else{
		strTemp2 = "Internal (Held inside the company)";
	}
%>	
		
                <option value="0"><%=strTemp2%></option>
                <%
								if(bolIsSchool){
								 	if (strSchCode.startsWith("CPU")) 
										strTemp2 = "External (Conducted by Other Groups & Attended by CPU Employees) ";
									else
										strTemp2 = "External (Held outside the campus)";
								}else{
									strTemp2 = "External (Held outside the company)";
								}
				if (strTemp.equals("1")){
				%>
                <option value="1" selected><%=strTemp2%></option>
                <%}else{%>
                <option value="1"><%=strTemp2%></option>
                <%}%>
              </select> </td>
          </tr>
          <tr> 
            <td height="25">Scope </td>
            <td height="25"> <select name="seminar_scope">
                <option value="">N/A</option>
<%
if (bNoError && strPrepareToEdit.compareTo("1") == 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else 
	strTemp = WI.fillTextValue("seminar_scope");
%>
                <%=dbOP.loadCombo("train_scope_index","train_scope"," FROM hr_preload_training_scope order by train_scope",strTemp,false)%> 
			</select></td>
          </tr>
          <tr> 
            <td height="25">Type</td>
            <td height="25">
<%
if (bNoError && strPrepareToEdit.compareTo("1") == 0) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
else 
	strTemp = WI.fillTextValue("seminar_type");
%>
			<select name="seminar_type">
                <option value = "">N/A</option>
            <%=dbOP.loadCombo("training_type_index","training_type"," FROM hr_preload_training_type order by training_type",strTemp,false)%> 

<!--
<%
if (strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                <option value="1" <%=strErrMsg%>>Official Time </option>
<%
if (strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                <option value="2" <%=strErrMsg%>>Official Business</option>
<%
if (strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
                <option value="3" <%=strErrMsg%>>Representative/Proxy</option>
-->
              </select>
			  
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
			  <a href='javascript:viewList("HR_PRELOAD_TRAINING_TYPE","TRAINING_TYPE_INDEX",
			"TRAINING_TYPE","TYPE OF TRAINING",	"HR_PRELOAD_MAND_TRAINING","TRAINING_TYPE_INDEX", 
			" and HR_PRELOAD_MAND_TRAINING.MAND_TRAINING_INDEX > 0","","seminar_type","64","1")'><img src="../../../images/update.gif" border="0"></a><font size="1">click to add to types of training </font>
<%}%>			  
			  </td>
          </tr>
          <tr> 
            <td height="25">Approved Budget</td>
            <%if (bNoError && strPrepareToEdit.compareTo("1") == 0) strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
	  else strTemp = WI.fillTextValue("approved_budget");%>
            <td height="25"><input name="approved_budget" type="text" size="12" maxlength="12" class="textbox"
			 onKeyUp="AllowOnlyFloat('staff_profile','approved_budget')"onFocus="style.backgroundColor='#D3EBFF'" 
			 value ="<%=strTemp%>" onBlur="style.backgroundColor='white';AllowOnlyFloat('staff_profile','approved_budget');" >
			 
<%	  if (bNoError && strPrepareToEdit.equals("1")) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(17));
	  else 
	  	strTemp = WI.fillTextValue("university_funded");
		
		if (strTemp.equals("1"))
			strTemp = " checked";
		else
			strTemp = "";
%>
			 <% if (strSchCode.startsWith("CPU")) {%> 
            &nbsp; <input type="checkbox" name="university_funded" value="1" <%=strTemp%>>
            <font size="1">check if university funded </font> </td>
			 <%}%> 
          </tr>
          <tr> 
            <td width="18%" height="25">Venue</td>
            <td width="80%" height="25"><input name="venue" type= "text" value="<%=WI.getStrValue(strTemp3)%>" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="venue" size="40"></td>
          </tr>

<% if (strSchCode.startsWith("CPU")) {

	if(bNoError && strPrepareToEdit.equals("1")){
		strTemp = (String)vEditInfo.elementAt(16);
	}else{
		strTemp = WI.fillTextValue("place");
	}
	
%> 
          <tr>
            <td height="25">Place </td>
            <td height="25"><input name="place" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="place" size="40"></td>
          </tr>
<%}
	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vEditInfo.elementAt(4);
		strTemp2 = (String) vEditInfo.elementAt(5);
		strTemp3 = (String) vEditInfo.elementAt(6);
	}else{
		strTemp = WI.fillTextValue("duration");
		strTemp2 = WI.fillTextValue("dIndex");
		strTemp3 = WI.fillTextValue("conductor");
	}
%>

          <tr> 
            <td height="25">Duration</td>
            <td height="25"><input name="duration" type= "text" class="textbox"  id="duration"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('staff_profile','duration')" onKeyUp="AllowOnlyFloat('staff_profile','duration')" value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4"> 
              <select name="dIndex" id="dIndex">
                <option value="0" selected>Hours</option>
                <%if (strTemp2.compareTo("1") == 0) {%>
                <option value="1" selected>Days</option>
                <%}else{%>
                <option value="1" >Days</option>
                <%}if (strTemp2.compareTo("2") == 0) {%>
                <option value="2" selected>Weeks</option>
                <%}else{%>
                <option value="2" >Weeks</option>
                <%}if (strTemp2.compareTo("3") == 0) {%>
                <option value="3" selected>Months</option>
                <%}else{%>
                <option value="3" >Months</option>
                <%}if(strTemp2.compareTo("4") == 0) {%>
                <option value="4" selected>Years</option>
                <%}else{%>
                <option value="4" >Years</option>
                <%}%>
              </select> </td>
          </tr>
          <tr> 
            <td height="25">Conducted by</td>
            <td height="25"><select name="conducted_by_index">
                <option value=""> Select Training Conductor </option>
                <%if (bNoError && strPrepareToEdit.compareTo("1") == 0) strTemp = (String)vEditInfo.elementAt(15);
	  else strTemp = WI.fillTextValue("conducted_by_index"); %>
                <%=dbOP.loadCombo("conducted_by_index","conducted_by"," FROM HR_PRELOAD_conducted_by order by conducted_by",strTemp,false)%> </select> 
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
				<a href='javascript:viewList("HR_PRELOAD_conducted_by","conducted_by_index","conducted_by","SEMINAR CONDUCTOR",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","conducted_by_index, conducted_by_index", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_APPL_INFO_TRAINING.is_del = 0","","conducted_by_index","256")'>	
              <img src="../../../images/update.gif" border="0"></a><font size="1">click to add to list </font>
<%}%>
			  </td>
          </tr>
          <%	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vEditInfo.elementAt(7);
		strTemp2 = (String) vEditInfo.elementAt(8);
		strTemp3 = (String) vEditInfo.elementAt(9);
	}else{
		strTemp = WI.fillTextValue("fdate");
		strTemp2 = WI.fillTextValue("tdate");
		strTemp3 = WI.fillTextValue("notes");
}%>
          <tr> 
            <td height="25">Inclusive Dates</td>
            <td height="25">From : 
              <input name="fdate" type="text"  value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" onKeyUP="AllowOnlyIntegerExtn('staff_profile','fdate','/')"> 
              <a href="javascript:show_calendar('staff_profile.fdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To: 
              <input name="tdate" type="text"  value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" onKeyUP="AllowOnlyIntegerExtn('staff_profile','tdate','/')"> 
              <a href="javascript:show_calendar('staff_profile.tdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;</td>
          </tr>
          <tr> 
            <td height="25" colspan="2"> Notes:<br> <textarea name="notes" cols="50" rows="2" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp3,"")%></textarea>            </td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><div align="center"> <br>
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0 || !bNoError){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
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
<%  if (vRetResult != null && vRetResult.size() > 0) { %>
        <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#666666"> 
            <td height="25" colspan="7" class="thinborder"><div align="center"><strong><font color="#FFFFFF">EMPLOYEE'S 
                TRAINING/SEMINAR RECORD</font></strong></div></td>
          </tr>
          <tr> 
            <td width="28%" align="center" class="thinborder"><strong>TRAINING 
              / SEMINARS</strong></td>
            <td width="17%" height="25" align="center" class="thinborder"><strong>TYPE 
              / BUDGET</strong></td>
            <td width="23%" align="center" class="thinborder"><strong>VENUE</strong></td>
            <td width="16%" align="center" class="thinborder"><strong>DATE</strong></td>
            <td width="5%" align="center" class="thinborder"><strong>DETAIL</strong></td>
            <td width="5%" align="center" class="thinborder"><strong>EDIT</strong></td>
            <td width="6%" align="center" class="thinborder"><strong>DELETE</strong></td>
          </tr>
          <% for (int i=0; i < vRetResult.size() ; i+=19) { %>
          <tr> 
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"<br> Conducted by : <strong>","</strong>","")%></td>
            <td class="thinborder">&nbsp;<%//=astrSemimarType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+14),"0"))]%> 
			<%=WI.getStrValue((String)vRetResult.elementAt(i+18)," - ")%>
			<%=WI.getStrValue((String)vRetResult.elementAt(i+13)," <br> &nbsp;Budget :","","")%></td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;") + 
				WI.getStrValue((String)vRetResult.elementAt(i+8),"<br>&nbsp; to ", "","")%></td>
            <td class="thinborder">
              <a href="javascript:viewDetail(<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>)"><img src="../../../images/view.gif" width="40" height="31" border="0"></a> 
            </td>
            <td class="thinborder"><%if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit(<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>)"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
              <%}else{%>
              N/A 
              <%}%></td>
            <td class="thinborder"><%if (iAccessLevel == 2) {%>
              <a href="javascript:DeleteRecord('<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>');"> 
              <img src="../../../images/delete.gif" border="0"></a> <%}else{%>
              N/A
              <%}%></td>
          </tr>
          <%} // end for loop %>
        </table>
		
		
        <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
            <td width="6%">&nbsp;</td>
          </tr>
          <tr>
            <td align="center"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a></td>
          </tr>
        </table>
 <%} // end table listing %>
      </td>
    </tr>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="print_page" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

