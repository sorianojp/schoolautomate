<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Personnel Licenses</title>
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
}

function viewInfo(){
	document.staff_profile.page_action.value = "";
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function CancelRecord(index)
{
	location = "./hr_personnel_licenses.jsp?applicant_="+document.staff_profile.applicant_.value+"&emp_id="+index+
	"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewExams(strFormField){
	var loadPg = "./hr_personnel_exams.jsp?" + 
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Licenses","hr_personnel_licenses.jsp");

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
															"hr_personnel_licenses.jsp");
}
else {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_licenses.jsp");
}											
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").equals("1"))
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
Vector vExamList = null;

boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining();

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
		vExamList = hrCon.getComboForExamsTaken(dbOP, (String)vEmpRec.elementAt(0),bolIsApplicant);
		bNoError = true;
	}else{		
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
			vRetResult = hrCon.operateOnLicense(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant license record removed successfully.";
					else
						strErrMsg = " Employee license record removed successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null) {
					if(bolIsApplicant)
						strErrMsg = " Applicant license record added successfully.";
					else
						strErrMsg = " Employee license record added successfully.";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					if(bolIsApplicant)
						strErrMsg = " Applicant license record edited successfully.";
					else
						strErrMsg = " Employee license record edited successfully.";
					strPrepareToEdit = "0";
				}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit != null && strPrepareToEdit.equals("1")){
	vRetResult = hrCon.operateOnLicense(dbOP,request,3);

	bNoError = false;

	if (vRetResult != null && vRetResult.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}

vRetResult = hrCon.operateOnLicense(dbOP,request,4);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolAllowUpdate = false;
if(strSchCode.startsWith("CIT"))
	bolAllowUpdate = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_licenses.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          LICENSES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="3" > <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="38%" height="25">&nbsp;&nbsp;
	  <%if(bolIsApplicant){%>
	  Applicant ID : <%}else{%>
	  Employee ID : <%}%>
		<input name="emp_id" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" 
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
  <% 	if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%"> 
        <hr size="1">
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
	strTemp = WI.fillTextValue("lindex");
	strTemp2 = WI.fillTextValue("license");
	strTemp3 = WI.fillTextValue("issuedate");
	if (bNoError && strPrepareToEdit.equals("1")){
		strTemp =  (String) vRetResult.elementAt(0);
		strTemp2 = (String) vRetResult.elementAt(2);
		strTemp3 = (String) vRetResult.elementAt(3);
	}
%>
		<table width="95%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr>
            <td width="1%" rowspan="9">&nbsp;</td>
            <td width="20%">License Name</td>
            <td><select name="lindex">
                <option value="">Select License</option>
                <%=dbOP.loadCombo("LICENSE_INDEX","LICENSE_NAME"," FROM HR_PRELOAD_LICENSE order by license_name",strTemp,false)%>
              </select> 
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_LICENSE","LICENSE_INDEX","LICENSE_NAME","LICENSE",
				"HR_INFO_LICENSE,HR_APPL_INFO_LICENSE","LICENSE_INDEX, LICENSE_INDEX", 
				" and HR_INFO_LICENSE.is_del = 0, and HR_APPL_INFO_LICENSE.is_del = 0","","lindex")'>			  
			  <img src="../../../images/update.gif" border="0"></a>
              <font size="1">click to add/edit list of licenses</font>
<%}%>			  </td>
          </tr>
          <tr>
            <td>License No.</td>
            <td><input name="license" type= "text" value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="16"></td>
          </tr>
          <tr>
            <td>Issued Date</td>
            <td><input name="issuedate" type= "text" 
				class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
				onblur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('staff_profile','issuedate','/')" value="<%=WI.getStrValue(strTemp3,"")%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('staff_profile.issuedate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <%
	strTemp = WI.fillTextValue("expirydate");
	strTemp2 = WI.fillTextValue("place");
	strTemp3 = WI.fillTextValue("remarks");
	if (bNoError && strPrepareToEdit.equals("1")){
		strTemp =  (String) vRetResult.elementAt(4);
		strTemp2 = (String) vRetResult.elementAt(5);
		strTemp3 = (String) vRetResult.elementAt(6);
	}
%>
          <tr>
            <td height="28">Expiry Date</td>
            <td><input name="expirydate" type= "text" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			 onKeyUp="AllowOnlyIntegerExtn('staff_profile','expirydate','/')" value="<%=WI.getStrValue(strTemp,"")%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('staff_profile.expirydate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr>
            <td height="28">Place Issued</td>
            <td height="28"><input name="place" type= "text" value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"  id="a_address232"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="40"></td>
          </tr>
          <tr>
            <td height="28">Exam Taken </td>
<%
	strTemp = WI.fillTextValue("exam_index");
	if (bNoError && strPrepareToEdit.equals("1")){
		strTemp =  (String) vRetResult.elementAt(8);
	}			
%>
            <td height="28">
			<select name="exam_index">
			<option value="">Select Exam Taken </option>				
			<% if(vExamList != null && vExamList.size() > 0) {
				for (int k = 0; k < vExamList.size() ; k+=3){
				  if (strTemp.equals((String)vExamList.elementAt(k))){ %>
			<option value="<%=(String)vExamList.elementAt(k)%>" selected>
					<%=(String)vExamList.elementAt(k+1) + 
							WI.getStrValue((String)vExamList.elementAt(k+2)," (",")","")%>					</option>
				<%}else{%>
			<option value="<%=(String)vExamList.elementAt(k)%>">
					<%=(String)vExamList.elementAt(k+1) + 
							WI.getStrValue((String)vExamList.elementAt(k+2)," (",")","")%>					</option>
	 		  <%  }
			  } // end for loop
			}%>
			</select>			
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
			<a href='javascript:viewExams("lindex")'><img src="../../../images/update.gif" border="0"></a>
<%}%>			
			</td>
          </tr>
          <tr>
            <td height="28" colspan="2">Remarks:<br>
              <textarea name="remarks" cols="50" rows="2" id="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp3,"")%></textarea></td>
          </tr>
          <tr>
            <td colspan="2">&nbsp; </td>
          </tr>
          <tr>
            <td colspan="3" align="center"> 
              <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0 || !bNoError){%>              <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
              <font size="1">click to save entries</font>
              <%}else{ %>              <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
              <font size="1">click to save changes</font>
              <%}}%>			  <a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font>              </td>
          </tr>
        </table>
		<br>
<% if (vRetResult != null && vRetResult.size() > 0) { %>
		<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
          <tr bgcolor="#666666"> 
            <td height="25" colspan="7" align="center" class="thinborder"><strong><font color="#FFFFFF">LIST 
              OF EMPLOYEE LICENSES</font></strong></td>
          </tr>
          <tr align="center"> 
            <td width="22%" height="25" class="thinborder"><strong>LICENSE NAME</strong></td>
            <td width="16%" class="thinborder"><strong>LICENSE NO.</strong></td>
            <td width="11%" class="thinborder"><font size="1"><strong>ISSUED DATE</strong></font></td>
            <td width="12%" class="thinborder"><font size="1"><strong>EXPIRY DATE</strong></font></td>
            <td width="25%" class="thinborder"><strong>REMARKS</strong></td>
            <td width="6%" class="thinborder"><strong>EDIT</strong></td>
            <td width="8%" class="thinborder"><strong>DELETE</strong></td>
          </tr>
          <% for (int i = 0; i < vRetResult.size() ; i+=11) { %>
          <tr> 
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
            <td class="thinborder"> 
              <% if (iAccessLevel > 1) {%>
              <input name="image4" type="image" onClick='PrepareToEdit("<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%>");' src="../../../images/edit.gif" width="40" height="26" border="0">
              <%}else{%>
              NA 
              <%}%>
            </td>
            <td class="thinborder"><% if (iAccessLevel == 2) {%>
              <input name="image5" type="image" onClick='DeleteRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%>");' src="../../../images/delete.gif" border="0"> 
              <%}else{%>
              NA 
              <%}%></td>
          </tr>
          <%} // end for loop %>
        </table>
<%} // end for listing table%>
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
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

