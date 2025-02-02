<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
 TD{
 	font-size: 11px;
 }
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateBefefit(strUserIndex, strDependentIndex) {
	var loadPg = "./hr_personnel_dep_benefit.jsp?user="+strUserIndex+"dependent="+
		strDependentIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}

function viewEmpTypes(){
	var win=window.open("./hr_emp_type.jsp","myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.consider_vedit.value = "1";//take edit info.
	document.form_.submit();
}
function FocusID() {
	if(document.form_.emp_id)
		document.form_.emp_id.focus();
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
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode ="";
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Service Record Hist.","hr_personnel_service_rec_hist.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_service_rec_hist.jsp");
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
Vector vEditInfo  = null;
Vector vEmpRec = null;Vector vTemp = null;

HRInfoServiceRecord hrSR = new HRInfoServiceRecord();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add,edit,delete
	if(hrSR.operateOnServiceRecord(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = hrSR.getErrMsg();
	else {
		strErrMsg = "Operation successful";
		strPrepareToEdit = "0";
	}	
		
}
//System.out.println("Before 1 : "+strErrMsg);
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrSR.operateOnServiceRecord(dbOP, request, 3);
	
	if(vEditInfo == null) 
		strErrMsg = hrSR.getErrMsg();
}//System.out.println("Before 2 : "+strErrMsg);
//get the list. 

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
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}
	vRetResult = hrSR.operateOnCurrentSR(dbOP, request, 4);//view all SR HISTORY.
%>

<body bgcolor="#FFFFFF" onLoad="focusID()">
<form action="./hr_personnel_service_rec_hist.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SERVICE RECORD HISTORY::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <% if (!bolMyHome){%>
    <tr valign="top"> 
      <td width="35%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="6%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
      </td>
      <td width="59%"><a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <label id="coa_info"></label>
	  </td>
    </tr>
    <%}else{%>
    <tr> 
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong> <input name="emp_id" type="hidden" value="<%=strTemp%>" >
      </td>
    </tr>
    <%}%>
  </table>
<% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
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
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br> 
<table width="92%" border="0" align="center" cellpadding="2" cellspacing="0">
<!--          <%// if(vEditInfo != null && vEditInfo.size() > 0) {%>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td width="21%">Length of Service</td>
            <td width="77%"> <strong><%//=(String)vEditInfo.elementAt(0)%></strong></td>
          </tr>
          <%//}%>
-->
<%if(bolIsSchool){%>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2">
	          <div align="center">
	            <% if(vEditInfo != null && vEditInfo.size() > 1) 
		strTemp = (String)vEditInfo.elementAt(27);
	else 
		strTemp = WI.fillTextValue("is_teach_staff");

   if(WI.getStrValue(strTemp).equals("1"))	strTemp2 = " checked";
	else strTemp2 = "";%>
                <input type="radio" name="is_teach_staff" value="1" <%=strTemp2%>>
	              <strong> Teaching &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
                  <% if(WI.getStrValue(strTemp).equals("0")) 	strTemp2 = " checked";
   else strTemp2 = "";%>
                  <input type="radio" name="is_teach_staff" value="0" <%=strTemp2%>>
                  Non-Teaching &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
                  <% 
  if (!strSchCode.startsWith("AUF"))  { 
  
  if(WI.getStrValue(strTemp).equals("2")) 	strTemp2 = " checked";
     else strTemp2 = "";%>
                  <input type="radio" name="is_teach_staff" value="2" <%=strTemp2%>>
                  Non-Teaching w/ Teaching Load
<%}%>
              </strong></div></td>
          </tr>
					<%}else{%>
					<input type="hidden" name="is_teach_staff" value="0">
					<%}%>
          <tr> 
            <td>&nbsp;</td>
            <td>Position</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("emp_type_index");
%> <select name="emp_type_index">
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%> </select> 
<%if(!bolMyHome){%>
				<a href='javascript:viewList("HR_EMPLOYMENT_TYPE","EMP_TYPE_INDEX","EMP_TYPE_NAME","Position/Employment Type");'> 
              <img src="../../../images/update.gif" border="0"></a>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td height="25">Employment Status</td>
            <td height="25" valign="bottom"> <select name="pt_ft">
                <option value="0"> Part Time</option>
                <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(28);
else	
	strTemp = WI.fillTextValue("pt_ft");
	
	if (strTemp.equals("1"))
		strTemp = "selected";
	else
		strTemp = ""; 	
%>
                <option value="1" <%=strTemp%>> 
                Full Time</option>
              </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Employment Tenure</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("status_index");
%> <select name="status_index">
                <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp, false)%> </select> 
<%if(!bolMyHome){%>
				<a href='javascript:viewList("user_status","status_index","status","EMPLOYEE STATUS",
		  			"USER_TABLE,USER_TABLE,HR_INFO_EMP_HIST,HR_APPL_INFO_EMP_HIST,HR_INFO_SERVICE_RCD",
					"CURRENT_STATUS,ENTRY_STATUS,EMP_STATUS_INDEX,EMP_STATUS_INDEX,STATUS",
					" and user_table.is_del = 0 and user_table.is_valid = 1, and user_table.is_del=0 and 
					user_table.is_valid = 1, and HR_INFO_EMP_HIST.is_del =0 and HR_INFO_EMP_HIST.is_valid =1,
					and HR_APPL_INFO_EMP_HIST.is_del = 0 and HR_APPL_INFO_EMP_HIST.is_valid =1,
					and HR_INFO_SERVICE_RCD.IS_VALID=1 and HR_INFO_SERVICE_RCD.is_del = 0 ", " is_for_student = 0")'><img src="../../../images/update.gif" border="0"></a>
<%}%>
					</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td><select name="c_index" onChange="ReloadPage();">
                <option value="0">N/A</option>
                <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
               <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> 
								<%if(bolIsSchool && !bolMyHome){%>
								<a href="javascript:AddMoreCollege();"><img src="../../../images/update.gif" border="0"></a> 
              <font size="1">click for multiple college</font>
								<%}%>
							</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><%=strTemp2%></td>
            <td> <select name="d_index">
                <option value="">All</option>
                <%
strTemp3 = "";
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp3 = (String)vEditInfo.elementAt(8);
else	
	strTemp3 = WI.fillTextValue("d_index");
%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Immediate Supervisor</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("supervisor");
	
if(strTemp == null)
	strTemp = "";
vTemp = hrSR.getSupervisorDetail(dbOP,request,(String)vEmpRec.elementAt(0),strTemp, strTemp3);

%> <select name="supervisor">
                <%
if(vTemp != null && vTemp.size() > 0){
	for(int i = 0; i < vTemp.size(); i += 2) {
		if(strTemp.compareTo((String)vTemp.elementAt(i)) == 0){%>
                <option value="<%=(String)vTemp.elementAt(i)%>" selected> 
                <%=(String)vTemp.elementAt(i + 1)%></option>
                <%}else{%>
                <option value="<%=(String)vTemp.elementAt(i)%>"> 
                <%=(String)vTemp.elementAt(i + 1)%></option>
                <%}
	}
}%>
              </select> <% if (WI.fillTextValue("inc_res").length() > 0) strTemp = "checked";
			  else strTemp = "";%> &nbsp; 
              <input name="inc_res" type="checkbox" id="inc_res" value="1" onClick="ReloadPage()" <%=strTemp%>> 
              <font size="1">inc. Resigned/Terminated Emp</font> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td><% if (bolIsSchool) {%> Academic Rank / <br> <%}%>
                    Job Grade</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("salary_grade");

vTemp = hrSR.getSalaryGradeDetail(dbOP);
%> <select name="salary_grade">
                <%
if(vTemp != null && vTemp.size() > 0 && false){///////////// not used.. 
	for(int i = 0; i < vTemp.size(); i += 5) {
		if(strTemp.compareTo((String)vTemp.elementAt(i)) == 0){%>
                <option value="<%=(String)vTemp.elementAt(i)%>" selected> 
                <%=(String)vTemp.elementAt(i + 1)+"  ("+(String)vTemp.elementAt(i + 2)+"-"+
		(String)vTemp.elementAt(i + 3)+")"%></option>
                <%}else{%>
                <option value="<%=(String)vTemp.elementAt(i)%>"> 
                <%=(String)vTemp.elementAt(i + 1)+"  ("+(String)vTemp.elementAt(i + 2)+"-"+
		(String)vTemp.elementAt(i + 3)+")"%></option>
                <%}
	}
}%>
              
<%
if(vTemp != null && vTemp.size() > 0){
	for(int i = 0; i < vTemp.size(); i += 5) {
	
		if (!strSchCode.startsWith("UI") &&  !strSchCode.startsWith("CPU")
			&&  !strSchCode.startsWith("AUF") && false){
			strTemp2 = (String)vTemp.elementAt(i + 1)+ "  ("+(String)vTemp.elementAt(i + 2)+
				WI.getStrValue((String)vTemp.elementAt(i + 3)," - ","","")+")";
		}else{
			strTemp2 = (String)vTemp.elementAt(i + 1);
		}		
	
		if(strTemp.equals((String)vTemp.elementAt(i))){%>
			<option value="<%=(String)vTemp.elementAt(i)%>" selected><%=strTemp2%>
				<%if(strSchCode.startsWith("AUF")){%>
				<%=WI.getStrValue((String)vTemp.elementAt(i+4), " (", ")", "")%><%}%></option>
        <%}else{%>
			<option value="<%=(String)vTemp.elementAt(i)%>"><%=strTemp2%>
				<%if(strSchCode.startsWith("AUF")){%>
				<%=WI.getStrValue((String)vTemp.elementAt(i+4), " (", ")", "")%><%}%></option>
        <%}
	}
}%>
			  
			  
			  
			  
			  
			  </select> </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><hr color="#0000DD" size="1"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Inclusive Dates</td>
            <td><font size="1"> 
              <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(18);
else	
	strTemp = WI.fillTextValue("valid_fr");
%>
              <input name="valid_fr" type="text" size="12" maxlength="12" 
			  onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" class="textbox"
			  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','valid_fr','/')"
			  onKeyUp="AllowOnlyIntegerExtn('form_','valid_fr','/')">
              <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp; </td>
            <td><font size="1"> 
              <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(19);
else	
	strTemp = WI.fillTextValue("valid_to");
strTemp = WI.getStrValue(strTemp);
%>
              <input name="valid_to" type="text" size="10" maxlength="10"
			   value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			   onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','valid_to','/')"
			   onKeyUp="AllowOnlyIntegerExtn('form_','valid_to','/')">
              <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              </font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25"> 
	<%if(bolIsSchool){%>					
<% if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(28));
else	
	strTemp = WI.fillTextValue("appointed_chancellor");
	
	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%> <input type="checkbox" name="appointed_chancellor" value="1" <%=strTemp%>> 
              <font size="1"> tick if Appointed by Chancellor</font>&nbsp;&nbsp;&nbsp;
	<%}%>			  
<% if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(30));
else	
	strTemp = WI.fillTextValue("is_additional");
	
	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%> <input type="checkbox" name="is_additional" value="1" <%=strTemp%>> 
              <font size="1"> tick if Additional Responsibility</font>			  
			  
			   </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"> <hr color="#0000DD" size="1"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Remarks</td>
            <% if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(30));
else	
	strTemp = WI.fillTextValue("sr_remarks");
%>
            <td><input name="sr_remarks" type="text" size="48" maxlength="128" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td colspan="2"> <div align="center"> 
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%>
                <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{ %>
                <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> 
                <% }
}%>
                <a href="./hr_personnel_service_rec_hist.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> </div></td>
          </tr>
          <tr> 
            <td height="26">&nbsp;</td>
            <td colspan="2">&nbsp;</td>
          </tr>
        </table>
 <%//}//only if vEditInfo is not null;
 
 if (vRetResult != null && vRetResult.size() > 0) {%>
 <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2" valign="bottom"><div align="right"><img src="../../../images/print.gif"  border="0"><font size="1">click to print Service Record</font></div></td>
    </tr>
  </table>
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#000000">
          <tr bgcolor="#666666"> 
            <td height="25" colspan="10"><div align="center"><strong><font color="#FFFFFF"><strong>SERVICE 
                RECORD </strong></font></strong></div></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td width="10%"><font size="1"><strong>POSITION</strong></font></td>
            <td width="14%"><font size="1"><strong>DEPT /OFFICE</strong></font></td>
            <td width="13%"><strong><font size="1"><strong>INCLUSIVE DATES</strong></font></strong></td>
            <td width="7%"> <font size="1"><strong>STATUS</strong></font></td>
            <td width="8%"><font size="1"><strong>TENURE</strong></font></td>
			<% if (strSchCode.startsWith("AUF"))
					strTemp = "RANK";
				else
					strTemp = "SALARY SCALE";
			%>
					
            <td width="13%"><font size="1"><strong><%=strTemp%></strong></font></td>
		 <% if (!strSchCode.startsWith("AUF")) {%>
            <td width="10%"><strong><font size="1"><strong>BENEFITS</strong></font></strong></td>
            <td width="10%"><font size="1"><strong>INCENTIVES</strong></font></td>
		 <%}%> 
            <td width="7%"><font size="1"><b>EDIT</b></font></td>
            <td width="8%"><font size="1"><b>DELETE</b></font></td>
          </tr>
          <%  
		  String[] astrPTFT = {"PT", "FT"};
		  for (int i = 1; i < vRetResult.size(); i +=31){
		  if(vRetResult.elementAt(i + 18) == null)
		  	continue;%>
          <tr bgcolor="#FFFFFF"> 
            <td height="55"><%=(String)vRetResult.elementAt(i + 2)%></td>
            <td><%=WI.getStrValue(vRetResult.elementAt(i + 6))%><%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"<br>","","")%></td>
            <td><%=(String)vRetResult.elementAt(i + 17)%> - <%=(String)vRetResult.elementAt(i + 18)%></td>
            <td><%=astrPTFT[Integer.parseInt((String)vRetResult.elementAt(i + 28))]%> </td>
            <td><%=(String)vRetResult.elementAt(i + 4)%></td>
		<% 
				strTemp = (String)vRetResult.elementAt(i + 12);
			if (!strSchCode.startsWith("AUF"))
				strTemp += "(" + (String)vRetResult.elementAt(i + 13)+")";
		 %>
            <td align="center"><%=strTemp%></td>
		<% if (!strSchCode.startsWith("AUF")) {%> 
            <td><%=WI.getStrValue(vRetResult.elementAt(i + 15),"Not set")%></td>
            <td><%=WI.getStrValue(vRetResult.elementAt(i + 16),"Not set")%></td>
		 <%}%>
            <td><%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'> 
              <img src="../../../images/edit.gif" border="0"></a> <%}%> </td>
            <td> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
              <img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
          </tr>
          <% } // end for loop %>
        </table>
<%}//end of if(vRetResult is not null) %>
      </td>
    </tr>
  </table>
<%}//if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1 -- most outer loop.%>
  <input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="consider_vedit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
