<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoServiceRecord,hr.OldServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request); 
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
	String strShowName = "0";
	if(strSchCode.startsWith("AUF"))
		strShowName = "1";
	
//	strSchCode = "UI";

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
	
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<style type="text/css">
.fontsize{
	font-size: 11px;
}
</style>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function UpdateBefefit(strUserIndex, strDependentIndex) {
	var loadPg = "./hr_personnel_dep_benefit.jsp?user="+strUserIndex+"dependent="+
		strDependentIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.submit();
}

function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.print_page.value="";
	document.form_.submit();
}
function viewEmpTypes(){
	var win=window.open("./hr_emp_type.jsp?opner_form_name=form_","myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddMoreCollege() {
	if(document.form_.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "../../user_admin/profile_add_more.jsp?emp_id="+escape(document.form_.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EditSR(strInfoIndex) {
	var loadPg = "./hr_personnel_service_rec_hist.jsp?info_index="+strInfoIndex+
	"&prepareToEdit=1&emp_id="+escape(document.form_.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewConcurrentPosts() {
	var loadPg = "./hr_personnel_service_rec.jsp?show_concurrent=1"+"&emp_id="+escape(document.form_.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function AddBenefit() {
	if(document.form_.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "./hr_personnel_service_rec_benefit.jsp?emp_id="+escape(document.form_.emp_id.value);
	var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateOldServiceRec(strSYFrom, strSYTo, strSem) {
	location = "../old_service_record_mgmt/old_service_record_mgmt.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strSem+
		"&emp_id="+document.form_.emp_id.value+"&cur_id="+document.form_.emp_id.value;
}

function focusID() {
<% if(!WI.fillTextValue("my_home").equals("0")){%>
	document.form_.emp_id.focus();
<%}%>
}

function EncodeSalaryRates(){
	if(document.form_.emp_id.value.length == 0){
		alert("Please enter employee ID.");
		return;
	}
	//pop window here. 
	var loadPg = "../../payroll/salary_rate/salary_rate.jsp?emp_id="+escape(document.form_.emp_id.value)+"&opner_form_name=form_";
	var win=window.open(loadPg,"SalaryEncode",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	
	if (WI.fillTextValue("print_page").compareTo("1") == 0){%>
		<jsp:forward page="./hr_personnel_service_rec_print.jsp" />
<% return;}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Service Record","hr_personnel_service_rec.jsp");
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
														"hr_personnel_service_rec.jsp");
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
Vector vEmpRec = null;
Vector vTemp = null;

boolean bolErrInEdit = false;//true if error while editing.

HRInfoServiceRecord hrSR = new HRInfoServiceRecord();
OldServiceRecord oSR = new OldServiceRecord();

strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0) {//add,edit,delete
	if(hrSR.operateOnCurrentSR(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg = hrSR.getErrMsg();
		if(strTemp.equals("2")) 
			bolErrInEdit = true;
	}
	else	
		strErrMsg = "Operation successful.";
}
//collect information to display.

String strCurrentID = WI.fillTextValue("emp_id");
if(strCurrentID.length() == 0)
	strCurrentID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strCurrentID);
strCurrentID = WI.getStrValue(strCurrentID);

if (WI.fillTextValue("emp_id").length() == 0 && strCurrentID.length() > 0){
	request.setAttribute("emp_id",strCurrentID);
}
if (strCurrentID.trim().length()> 1){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}
Vector vLoad = null;
if(strCurrentID.length() > 0 && vEmpRec != null) {
	vEditInfo = hrSR.operateOnCurrentSR(dbOP, request, 5);

	if(vEditInfo == null)
		strErrMsg = hrSR.getErrMsg();
		
	vRetResult = hrSR.operateOnServiceRecord(dbOP, request, 4);
	
	if (vRetResult == null) 
		strErrMsg = hrSR.getErrMsg();

	vLoad = oSR.operateOnOldServiceRecord (dbOP, request, 6);

//	System.out.println("vLoad : " + vLoad);
//	if (vLoad == null) 
//		strErrMsg = oSR.getErrMsg();
	
}


%>

<body bgcolor="#ffffff" onLoad="focusID();">	
<form action="./hr_personnel_service_rec.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" align="center" bgcolor="#cccccc"> <strong>:::: 
        SERVICE RECORD::::</strong></td>
    </tr>
    <tr> 
      <td height="30" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
<% if (!bolMyHome  && !WI.fillTextValue("show_concurrent").equals("1")){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strCurrentID%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
	  </td>
      <td width="57%"> <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   <label id="coa_info"></label>
	  </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strCurrentID%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strCurrentID%>" ></td>
    </tr>
<%}%>
  </table>
<% if (vEmpRec !=null && vEmpRec.size() > 0 && strCurrentID.trim().length() > 1){%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%"> 
<% if (!bolMyHome){%>
	  <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
<% }// end if !bolMyHome%>
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strCurrentID.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
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
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font>
		<%if(strSchCode.startsWith("AUF")){%>
			  <br><font size="1"><%=(String)vEmpRec.elementAt(16)%></font>
		<%}%>
              <br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) {
	if (!bolMyHome) {
%>
        <table width="97%" border="0" align="center" cellpadding="0" cellspacing="0">
<% if (!strSchCode.startsWith("AUF")) {%> 
          <tr bgcolor="#D5D5EA"> 
            <td width="20%">&nbsp;Length of Service</td>
            <td width="80%" height="25"> <strong><%=(String)vEditInfo.elementAt(0)%></strong></td>
          </tr>
<% }
if(bolIsSchool){%>
          <tr> 
            <td height="25" colspan="2"> 
              <div align="center">
                <% if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
		strTemp = (String)vEditInfo.elementAt(27);
	else 
		strTemp = WI.fillTextValue("is_teach_staff");

   if(WI.getStrValue(strTemp).compareTo("1") == 0)	strTemp2 = " checked";
	else strTemp2 = "";%> 
                <input type="radio" name="is_teach_staff" value="1" <%=strTemp2%>> 
                  <strong> Teaching &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; 
                  <% if(WI.getStrValue(strTemp).compareTo("0") == 0) 	strTemp2 = " checked";
   else strTemp2 = "";%>
                  <input type="radio" name="is_teach_staff" value="0" <%=strTemp2%>>
                  Non-Teaching &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; 
                  <% 
  if (!strSchCode.startsWith("AUF"))  { 
  
  if(WI.getStrValue(strTemp).compareTo("2") == 0) 	strTemp2 = " checked";
     else strTemp2 = "";%>
                  <input type="radio" name="is_teach_staff" value="2" <%=strTemp2%>>
                  Non-Teaching w/ Teaching Load
                  <%}%> 
                    
                </strong> </div></td>
          </tr>
<%}else{%><input type="hidden" name="is_teach_staff" value="0">
<%}%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom"><font size="1"> 
              <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('form_.starts_with','form_.emp_type_index',true);">
              </font><font size="1">scroll position</font></td>
          </tr>
          <tr> 
            <td height="25" class="fontsize">Position</td>
            <td height="25" valign="bottom"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="39%" height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("emp_type_index");
	
if ( !strCurrentID.equals(WI.fillTextValue("current_id")) ){
	strTemp = (String)vEmpRec.elementAt(9);
}

%> <select name="emp_type_index">
                      <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%> </select> </td>
                  <td width="61%">
<%if(!bolMyHome && iAccessLevel > 1){%>
				  <a href='javascript:viewEmpTypes()'><img src="../../../images/update.gif" border="0"></a> 
                    <font size="1"> add Position to list</font>
<%}%>
				  </td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td height="25" class="fontsize">Employment Status</td>
            <td height="25" valign="bottom"><select name="pt_ft">
                <option value="0"> Part Time</option>
                <%
				
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(29);
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
            <td height="25" class="fontsize">Employment Tenure</td>
            <td height="25" valign="bottom"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="15%" height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("status_index");
	
if (!strCurrentID.equals(WI.fillTextValue("current_id")) ){
	strTemp = (String)vEmpRec.elementAt(10);
}


%>
                    <select name="status_index">
                      <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",strTemp, false)%> 
                    </select> </td>
                  <td>
<%if(!bolMyHome && iAccessLevel > 1){%>
				  <a href='javascript:viewList("user_status","status_index","status","EMPLOYEE STATUS",
		  			"USER_TABLE,USER_TABLE,HR_INFO_EMP_HIST,HR_APPL_INFO_EMP_HIST,HR_INFO_SERVICE_RCD",
					"CURRENT_STATUS,ENTRY_STATUS,EMP_STATUS_INDEX,EMP_STATUS_INDEX,STATUS",
					" and user_table.is_del = 0 and user_table.is_valid = 1, and user_table.is_del=0 and 
					user_table.is_valid = 1, and HR_INFO_EMP_HIST.is_del =0 and HR_INFO_EMP_HIST.is_valid =1,
					and HR_APPL_INFO_EMP_HIST.is_del = 0 and HR_APPL_INFO_EMP_HIST.is_valid =1,
					and HR_INFO_SERVICE_RCD.IS_VALID=1 and HR_INFO_SERVICE_RCD.is_del = 0 ", " is_for_student = 0","status_index")'><img src="../../../images/update.gif" border="0"></a> 
                    <font size="1"> add an EMPLOYMENT STATUS to list</font> 
<%}%>
				  </td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td height="25" class="fontsize"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25" valign="bottom"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="41%" height="25"><select name="c_index" onChange="loadDept();">
                      <option value="0">N/A</option>
                      <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("c_index");

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.equals("0"))
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
	
if (!strCurrentID.equals(WI.fillTextValue("current_id")) ){
	strTemp = (String)vEmpRec.elementAt(11);
}
%>
                      <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
                  <td><%if(bolIsSchool && !bolMyHome && iAccessLevel > 1){%><a href="javascript:AddMoreCollege();"><img src="../../../images/update.gif" border="0"></a> 
                    <font size="1"> add MULTIPLE 
										<%}%></font></td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td height="25" class="fontsize"><%=strTemp2%></td>
            <td height="25" valign="bottom">
						<label id="load_dept">
						<select name="d_index">
                <option value="">All</option>
                <% strTemp3 = "";
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp3 = (String)vEditInfo.elementAt(8);
else strTemp3 = WI.fillTextValue("d_index");

if (strTemp != null && strTemp.compareTo("0") !=  0) strTemp = " (c_index =" + strTemp + ")";
    else strTemp = "(c_index = 0 or c_index is null)";
	
if (!strCurrentID.equals(WI.fillTextValue("current_id")) ){
	strTemp3 = (String)vEmpRec.elementAt(12);
}
%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and  "+strTemp+" order by d_name asc",strTemp3, false)%> </select>
			  </label>
			</td>
          </tr>
          <tr> 
            <td height="25" colspan="2"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="20%" height="25">&nbsp;</td>
                  <td height="25"><font size="1"> 
                    <input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="25" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('form_.starts_with2','form_.supervisor',true);">
                    scroll supervisor</font> </td>
                </tr>
                <tr> 
                  <td height="25" class="fontsize">Immediate Supervisor</td>
                  <td height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 	strTemp = (String)vEditInfo.elementAt(10);
else strTemp = WI.fillTextValue("supervisor");

vTemp = hrSR.getSupervisorDetail(dbOP,request,(String)vEmpRec.elementAt(0),strTemp, strTemp3);

%> <select name="supervisor">
                      <%if(vTemp != null && vTemp.size() > 0){
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
                    </select> 
<% if (WI.fillTextValue("inc_res").length() > 0) 
		strTemp = "checked";
	else strTemp = "";
%> <font size="1">&nbsp; </font> 
	<input name="inc_res" type="checkbox" id="inc_res" value="1" onClick="ReloadPage()" <%=strTemp%>> 
                    <font size="1">inc. Resigned/Terminated Employees</font></td>
                </tr>
                <tr> 
                  <td height="25" class="fontsize"><% if (bolIsSchool) {%> Academic Rank / <br> <%}%>
                    Job Grade</td>
                  <td height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(12);
else	
	strTemp = WI.fillTextValue("salary_grade");

vTemp = hrSR.getSalaryGradeDetail(dbOP);//System.out.println(vTemp);
 %> <select name="salary_grade">
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
                    </select>
<% if (strSchCode.startsWith("CPU") || strSchCode.startsWith("UI")) {%> 
					<a href="javascript:EncodeSalaryRates()">View Encoded Salary Rate </a>
<%}%>				  </td>
                </tr>
                <tr> 
                  <td height="25" colspan="2"><hr size="1" color="#0000FF"></td>
                </tr>
<%if (!strSchCode.startsWith("AUF")) {
	if (!strSchCode.startsWith("CLC")) {
%> 
                <tr> 
                  <td height="25" class="fontsize">Benefits/Incentives</td>
                  <td height="25"> <a href="javascript:AddBenefit();"> <img src="../../../images/update.gif" border="0"></a> 
                    <font size="1">click to record benefits/incentives for this 
                    employee</font></td>
                </tr>
<%}
}%>
                <tr> 
                  <td height="25" class="fontsize">Inclusive Dates</td>
                  <td height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(18);
else	
	strTemp = WI.fillTextValue("valid_fr");
%> <input name="valid_fr" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  onKeyUP="AllowOnlyIntegerExtn('form_','valid_fr','/')"> 
                    <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
                </tr>
                <%//}//show only if vEditInfo.size () > 1)
//else if (vEditInfo != null){%>
                <tr> 
                  <td height="25">&nbsp; </td>
                  <td height="25"> <%
if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(19);
else	
	strTemp = WI.fillTextValue("valid_to");
strTemp = WI.getStrValue(strTemp);
%> <input name="valid_to" type="text" size="10" maxlength="10" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"   onKeyUP="AllowOnlyIntegerExtn('form_','valid_to','/')"> 
                    <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
                    <font size="1"> (for current Service Record leave inclusive 
                    date to empty.)</font></td>
                </tr>
                <%//}
				if (strSchCode.startsWith("AUF")){
					if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
						strTemp = (String)vEditInfo.elementAt(28);
					else	
						strTemp = WI.fillTextValue("appointed_chancellor");
						
					if (strTemp.equals("1")) 
						strTemp = "checked";
					else
						strTemp ="";
				%>
                <tr> 
                  <td height="25">&nbsp;</td>
                  <td height="25"><input type="checkbox" name="appointed_chancellor" value="1" <%=strTemp%>> 
                    <font size="1"> tick if Appointed by Chancellor</font> &nbsp;&nbsp;
<% 	


			if (!WI.fillTextValue("show_concurrent").equals("1")) { 
				if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
					strTemp = (String)vEditInfo.elementAt(31);
				else	
					strTemp = WI.fillTextValue("is_additional");
						
				if (strTemp.equals("1")) 
					strTemp = "checked";
				else
					strTemp ="";
%>	
					<input type="checkbox" name="is_additional" value="1" <%=strTemp%>> 
                    <font size="1"> tick if Additional Job</font>
					&nbsp;&nbsp;&nbsp;
					<a href="javascript:viewConcurrentPosts()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>
					<font size="1">view concurrent post</font></td>
                </tr>
                <%} // show concurrent posts
				} // end if (strSchCode.startsWith("AUF")){
				
				%>
                <tr> 
                  <td height="25" colspan="2" class="fontsize"><hr size="1" color="#0000FF"></td>
                </tr>
                <tr> 
                  <td height="25" class="fontsize">Remarks </td>
<% if(!bolErrInEdit && vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(30));
else	
	strTemp = WI.fillTextValue("sr_remarks");
%>
                  <td height="25"><textarea name="sr_remarks" cols="48" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
                </tr>
<% if (false && vEditInfo != null && vEditInfo.size() > 1) {%> 
                <tr> 
                  <td height="25">&nbsp;</td>
                  <td height="25" align="right">&nbsp;</td>
                </tr>
<%}%> 
                <tr>
                  <td height="25" colspan="2">&nbsp;</td>
                </tr>
                <tr> 
                  <td height="25" colspan="2"> <div align="center"> <font size="1"> 
                      <% if (iAccessLevel > 1){
	if (vEditInfo != null && vEditInfo.size() == 1){%>
                      <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                      click to save entries <a href="./hr_personnel_service_rec.jsp"><img src="../../../images/cancel.gif" border="0"></a>click 
                      to cancel/ clear entries 
                      <%}else{ %>
					  <a href='javascript:PageAction("","6");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                      click to add a new service record
                      <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
                      click to save changes 
                      <% }
}%>
                      </font></div></td>
                </tr>
                <tr> 
                  <td height="25" colspan="2">&nbsp;</td>
                </tr>
              </table></td>
          </tr>
        </table>
        <% } // my home --> do not show
 }//only if vEditInfo is not null;

//	System.out.println(vRetResult);
	
 if (vRetResult != null && vRetResult.size() > 1) {%>
		<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" >
		<%if(strSchCode.startsWith("AUF")){%>
          <tr>
            <td colspan="2" align="right">
				Verified by:&nbsp;
				<input type="text" name="verified_by" value="<%=WI.fillTextValue("verified_by")%>" size="32" class="textbox"
		  			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px"></td>
          </tr>
          <tr>
            <td colspan="2" align="right">
				Noted by:&nbsp;
				<input type="text" name="noted_by" value="<%=WI.fillTextValue("noted_by")%>" size="32" class="textbox"
		  			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px"></td>
          </tr>
		<%}%>
          <tr>
            <td width="50%">&nbsp;
			<% if (WI.fillTextValue("do_not_get_incentives").equals("1")) 	
					strTemp = "checked";
				else
					strTemp = ""; %>
			<input type="checkbox" name="do_not_get_incentives" value="1" <%=strTemp%> onClick="ReloadPage();"> Show incentives			</td> 
            <td width="50%" align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif"  border="0"></a><font size="1">click 
                to print Service Record</font></td>
          </tr>
		</table>
		<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr bgcolor="#666666"> 
            <td height="25" bgcolor="#E4EEFC" class="thinborder"><div align="center"><strong>SERVICE 
                RECORD </strong></div></td>
          </tr>
	    </table>
        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr bgcolor="#FFFFFF"> 
            <td width="13%" bgcolor="#FFFFFF" class="thinborder"><div align="center"><font size="1"><strong>POSITION</strong></font></div></td>
            <td width="18%" class="thinborder"><div align="center"><font size="1"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/ 
                DEPT /OFFICE</strong></font></div></td>
            <td width="16%" align="center" bgcolor="#FFFFFF" class="thinborder"><strong><font size="1">INCLUSIVE 
              DATES</font></strong></td>
            <td width="16%" align="center" bgcolor="#FFFFFF" class="thinborder"><strong><font size="1">JOB RANK</font></strong></td>
            <td width="9%" align="center" bgcolor="#FFFFFF" class="thinborder"><strong> <font size="1">STATUS</font></strong></td>
            <td width="10%" align="center" bgcolor="#FFFFFF" class="thinborder"><font size="1"><strong>TENURE</strong></font></td>
            <td width="10%" align="center" bgcolor="#FFFFFF" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
            <% if (WI.fillTextValue("do_not_get_incentives").equals("1")){%> 
            <td width="10%" align="center" bgcolor="#FFFFFF" class="thinborder"><strong><font size="1">BENEFITS</font></strong></td>
            <td width="10%" class="thinborder"><font size="1"><strong>INCENTIVES</strong></font></td>
<%}
			if (!bolMyHome){%>
            <td width="7%" class="thinborder"><font size="1"><b>EDIT</b></font></td>
            <td width="7%" bgcolor="#FFFFFF" class="thinborder"><font size="1"><b>DELETE</b></font></td>
            <%}%>
          </tr>
          <%
		  String[] astrPTFT = {"PT", "FT"};
		  String[] astrPTFTFull = {"Part-Time", "Full-Time"};
		  for (int i = 1; i < vRetResult.size(); i +=31){
		  	strTemp = (String)vRetResult.elementAt(i + 6);
			if (strTemp != null) 
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i + 8)," :: ","","");
			else strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 8));
		  %>
          <tr bgcolor="#FFFFFF"> 
            <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
            <td class="thinborder"><font size="1"><%=strTemp%></font></td>
            <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i + 17)%> 
              <%=WI.getStrValue((String)vRetResult.elementAt(i + 18)," - <br>",""," - present")%></font></td>
            <td class="thinborder"><%=(String)vRetResult.elementAt(i + 12)%></td>
            <td class="thinborder">&nbsp;<%=astrPTFT[Integer.parseInt((String)vRetResult.elementAt(i + 28))]%> </td>
			<% if (((String)vRetResult.elementAt(i + 28)).equals("0") && strSchCode.startsWith("AUF")) 
				strTemp = "&nbsp";
			   else
			   	strTemp = (String)vRetResult.elementAt(i + 4);
			%>
            <td class="thinborder"><font size="1"><%=strTemp%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i + 29),"&nbsp;")%></font></td>
            <% if (WI.fillTextValue("do_not_get_incentives").equals("1")) {%> 
            <td class="thinborder"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 15),"--")%></font></td>
            <td class="thinborder"><font size="1"> <%=WI.getStrValue(vRetResult.elementAt(i + 16),"--")%></font></td>
<%} 
		 if (!bolMyHome){%>
            <td class="thinborder"><%if(iAccessLevel > 1 && vRetResult.elementAt(i + 18) != null){%> <a href='javascript:EditSR(<%=(String)vRetResult.elementAt(i)%>);'> 
              <img src="../../../images/edit.gif" border="0"></a> <%}else{%>
              NA 
              <%}%></td>
            <td class="thinborder"> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
              <img src="../../../images/delete.gif" border="0"></a> <%}else{%>NA<%}%> </td>
            <%}%>
          </tr>
          <% } // end for loop %>
        </table>
<%}//end of if(vRetResult is not null) %>
      </td>
    </tr>
  </table>
<%
if (vLoad!=null && vLoad.size()>0 && strSchCode.startsWith("UI")){%>  

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" align="right" class="thinborder">
	  	<a href="javascript:PrintPg()"><img src="../../../images/print.gif"  border="0"></a>
			<font size="1">click to print Service Record</font></td>
    </tr>

    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#E4EEFC" class="thinborder"><strong>Faculty Teaching Load Detail</strong></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong>School Year</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>Term</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>Total Load</strong></div></td>
      <td width="42%" class="thinborder"><div align="center"><strong>Subjects</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>Service Credit</strong> </div></td>
      <td width="7%" class="thinborder"><strong>Total Credit</strong> </td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
<%	double dTotalCredit = 0d; String strSYFrom = null;String strSYTo = null; String strSem = null;
	String strServiceCredit = null;
	String [] astrSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};		
	for (int i = 0; i< vLoad.size(); i+=10){
	strServiceCredit = (String)vLoad.elementAt(i+9);
	dTotalCredit += Double.parseDouble(WI.getStrValue(strServiceCredit,"0"));
	strTemp = (String)vLoad.elementAt(i+1);
	
	strSYFrom = (String)vLoad.elementAt(i+2);
	strSYTo   = (String)vLoad.elementAt(i+3);
	strSem    = (String)vLoad.elementAt(i+4);
	%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+2)%>&nbsp;-&nbsp;<%=(String)vLoad.elementAt(i+3)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1">
      <%=astrSem[Integer.parseInt((String)vLoad.elementAt(i+4))]%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+5)%></font></div></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
      <% for (i += 10;i< vLoad.size(); i+=10){
      if ( ((String)vLoad.elementAt(i+1)).compareTo(strTemp) == 0 ){%>
      ,<%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
      <%}else{
      		i-=10;
	      break;
	    }
	 }%>
      </font></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strServiceCredit,"-")%></td>
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
      <td class="thinborder"><a href="javascript:UpdateOldServiceRec('<%=strSYFrom%>','<%=strSYTo%>','<%=strSem%>');">Update</a></td>
    </tr>
    <%}%>
  </table>
  
  
<% } // end if vLoad is ! null
}//if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1 -- most outer loop.

if(vEditInfo != null && vEditInfo.size() > 1)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("info_index");
%>

<% if (WI.fillTextValue("show_concurrent").equals("1")) {%> 
	<input type="hidden" name="is_additional" value="1">
	<input type="hidden" name="is_additional" value="1">
<%}%> 

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="print_page" value="">
<input type="hidden" name="current_id" value="<%=strCurrentID%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="show_concurrent" value="<%=WI.fillTextValue("show_concurrent")%>">
<input type="hidden" name="show_name" value="<%=strShowName%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
