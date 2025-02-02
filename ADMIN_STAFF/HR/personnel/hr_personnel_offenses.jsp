<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoGAExtraActivityOffense"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

	

 %>	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Personnel Offense</title>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	document.staff_profile.print_page.value ="";
	this.SubmitOnce("staff_profile");
}

function viewInfo(){
	document.staff_profile.print_page.value ="";
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.print_page.value ="";


	// check if suspended.. 
	var strText = 
		document.staff_profile.action_index[document.staff_profile.action_index.selectedIndex].text;
	
	if (strText.toLowerCase().indexOf("suspen") == 0){
		document.staff_profile.is_suspended.value="1";
	}

	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.print_page.value ="";
	document.staff_profile.page_action.value="2";
	
	// check if suspended.. 
	var strText = 
		document.staff_profile.action_index[document.staff_profile.action_index.selectedIndex].text;
	
	if (strText.toLowerCase().indexOf("suspen") == 0){
		document.staff_profile.is_suspended.value="1";
	}
	
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.print_page.value ="";
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function CancelRecord(index)
{
	location = "././hr_personnel_offenses.jsp?emp_id="+index;
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

function PrintPage(){
	document.staff_profile.print_page.value ="1";
	this.SubmitOnce("staff_profile");
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

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

	if (WI.fillTextValue("print_page").compareTo("1")  == 0){%>
		<jsp:forward page="./hr_personnel_offenses_print.jsp" />
<%	return;}
//add security hehol.

	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Offenses","hr_personnel_offenses.jsp");

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
														"hr_personnel_offenses.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 1;

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


new hr.HRUpdateTables(dbOP);

Vector vEmpRec = null;
Vector vRetResult = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoGAExtraActivityOffense hrCon = new HRInfoGAExtraActivityOffense();


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

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");


	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnOffenses(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee offense record removed successfully.";
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee offense record added successfully.";
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee offense record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit.equals("1")){
	vEditResult = hrCon.operateOnOffenses(dbOP,request,3);

	bNoError = false;

	if (vEditResult != null && vEditResult.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}


//////////////////////// this is hard coded, before shifting to table.. 
//////////////////////// please note of the written values per School///////////

// added already to HR_PRELOAD_OFF_ACTION
/*
String astrConvAction[] = {"Warning","Written Reprimand", 
							"1st Notice", "2nd Notice",null,"Termination"};

if (strSchCode.startsWith("CPU")) {
	astrConvAction[0] = "Verbal";
	astrConvAction[1] = "Verbal Reprimand";
	astrConvAction[2] = "1st Written Warning";
	astrConvAction[3] = "2nd Written Warning";
	astrConvAction[4] = "Suspension";
	astrConvAction[5] = "Termination";
}

if (strSchCode.startsWith("CGH")) {
	astrConvAction[0] = "Written Reprimand";
	astrConvAction[1] = "Verbal Reprimand";
	astrConvAction[2] = "Suspension";
	astrConvAction[3] = "Dismissal";
	astrConvAction[4] = null;
	astrConvAction[5] = null;
}
*/


//////////////////////////// end hard coded  actions.. /////////////////////

vRetResult = hrCon.operateOnOffenses(dbOP,request,4);
	if (vRetResult != null && vRetResult.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}


%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">

<form action="./hr_personnel_offenses.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          OFFENSES RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
	  </td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
      <label id="coa_info"></label>
			</td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
  <%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
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
              <% if (!WI.getStrValue((String)request.getSession(false).getAttribute("school_code")).startsWith("UI")){%>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
              <%}%>
              </font>            </td>
          </tr>
        </table>
<% 	strTemp = WI.fillTextValue("offense");
	strTemp2 = WI.fillTextValue("details");
	strTemp3 = WI.fillTextValue("rdate");
	if (bNoError && strPrepareToEdit.equals("1")
		&& vEditResult != null && vEditResult.size()>0){
		strTemp = (String)vEditResult.elementAt(0);
		strTemp2 = (String)vEditResult.elementAt(2);
		strTemp3 = (String)vEditResult.elementAt(3);
	}
%>
        <br>
		<table width="99%" border="0" cellpadding="0" cellspacing="3">
          <tr>
            <td width="5%">&nbsp;</td>
            <td width="25%">Name of Offense </td>
            <td width="70%"><select name="offense" id="offense">
                <option value="">Select Offense</option>
                <%=dbOP.loadCombo("OFFENSE_NAME_INDEX","OFFENSE_NAME"," FROM HR_PRELOAD_OFFENSE order by offense_name",strTemp,false)%> </select> &nbsp; 
<%if(!bolMyHome && iAccessLevel > 1){%>
			  <a href='javascript:viewList("HR_PRELOAD_OFFENSE","OFFENSE_NAME_INDEX","OFFENSE_NAME","OFFENSE",
		  			" HR_INFO_OFFENSE"," OFFENSE_NAME_INDEX", 
					" and HR_INFO_OFFENSE.is_del = 0 and HR_INFO_OFFENSE.is_valid = 1", "","offense")'> 				
			  <img src="../../../images/update.gif" border="0"></a>              
<%}%>
			  </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Details</td>
            <td><textarea name="details" cols="40" rows="2" id="details" class="textbox"onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp2,"")%></textarea></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>Date of Offense/Reported</td>
            <td><input name="rdate" type= "text" value="<%=WI.getStrValue(strTemp3,"")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" onKeyUP="AllowOnlyIntegerExtn('staff_profile','rdate','/')">
              <a href="javascript:show_calendar('staff_profile.rdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
<% 	strTemp = WI.fillTextValue("action");
	strTemp2 = WI.fillTextValue("effectivedate");
	strTemp3 = WI.fillTextValue("effectivedateto");
	if (bNoError && strPrepareToEdit.compareTo("1") == 0
		&& vEditResult != null && vEditResult.size()>0){
		strTemp = (String)vEditResult.elementAt(4);
		strTemp2 = WI.getStrValue((String)vEditResult.elementAt(5));
		strTemp3 = WI.getStrValue((String)vEditResult.elementAt(7));
	}
	
//	System.out.println("strTemp : " + strTemp);
%>
          <tr>
            <td>&nbsp;</td>
            <td>Action Taken</td>
            <td><select name="action_index">
                <option value="">Select Action Taken</option>
                <%=dbOP.loadCombo("action_index","ACTION_NAME"," FROM HR_PRELOAD_OFFENSE_ACTION "+ 
				"  order by action_index",strTemp,false)%> </select>
              </select> 
<%if(!bolMyHome && iAccessLevel > 1){%>
			  <a href='javascript:viewList("HR_PRELOAD_OFFENSE_ACTION","action_index","action_name","ACTION",
		  			" HR_INFO_OFFENSE"," action", 
					" and HR_INFO_OFFENSE.is_del = 0 and HR_INFO_OFFENSE.is_valid = 1", "","action_index")'> 				
			  <img src="../../../images/update.gif" border="0"></a> 
<%}%>
			  </td>
          </tr>
        </table>
        <table width="99%" border="0" cellpadding="0" cellspacing="0">
          <% 	strTemp = WI.fillTextValue("action");
	strTemp2 = WI.fillTextValue("effectivedate");
	strTemp3 = WI.fillTextValue("effectivedateto");
	if (bNoError && strPrepareToEdit.equals("1") 
		&& vEditResult != null && vEditResult.size()>0){
		strTemp = (String)vEditResult.elementAt(4);
		strTemp2 = WI.getStrValue((String)vEditResult.elementAt(5));
		strTemp3 = WI.getStrValue((String)vEditResult.elementAt(7));
	}
	
//	System.out.println("strTemp : " + strTemp);
%>
          <tr>
            <td width="7%" height="18">&nbsp;</td>
            <td colspan="3" valign="bottom"><em>Inclusive Dates : </em></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td width="11%">&nbsp;</td>
            <% 	
	strTemp2 = WI.fillTextValue("effectivedate");
	strTemp3 = WI.fillTextValue("effectivedateto");
	if (bNoError && strPrepareToEdit.compareTo("1") == 0
		&& vEditResult != null && vEditResult.size()>0){
		strTemp2 = WI.getStrValue((String)vEditResult.elementAt(5));
		strTemp3 = WI.getStrValue((String)vEditResult.elementAt(7));
	}
%>
            <td width="29%">From  : 
              <input name="effectivedate" type= "text"class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('staff_profile','effectivedate','/')"  value="<%=WI.getStrValue(strTemp2,"")%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('staff_profile.effectivedate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"> </a></td>
            <td width="53%">To : 
              <input name="effectivedateto" type= "text"class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('staff_profile','effectivedateto','/')"  value="<%=strTemp3%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('staff_profile.effectivedateto');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
        </table>
        <table width="99%" border="0" cellpadding="0" cellspacing="0">
          <% 	strTemp = WI.fillTextValue("action");
	strTemp2 = WI.fillTextValue("effectivedate");
	strTemp3 = WI.fillTextValue("effectivedateto");
	if (bNoError && strPrepareToEdit.equals("1") 
		&& vEditResult != null && vEditResult.size()>0){
		strTemp = (String)vEditResult.elementAt(4);
		strTemp2 = WI.getStrValue((String)vEditResult.elementAt(5));
		strTemp3 = WI.getStrValue((String)vEditResult.elementAt(7));
	}
	
//	System.out.println("strTemp : " + strTemp);

%>
<!--
          <tr>
            <td width="5%" height="25">&nbsp;</td>
            <td width="25%" height="25" valign="top">EMPLOYEE EXPLANATION </td>
            <td width="70%" height="25"><textarea name="textarea" cols="40" rows="4" id="textarea" class="textbox"onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp2,"")%></textarea></td>
          </tr>
          <tr>
            <td height="25" colspan="3">&nbsp;</td>
          </tr>
-->
          <tr>
            <td colspan="3" align="center"><% if (iAccessLevel > 1){
		if (!strPrepareToEdit.equals("1") || !bNoError){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click to save entries</font>
                <%}else{ %>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> <font size="1">click to save changes</font> <a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                  to cancel and clear entries</font>
                <%}}%>            </td>
          </tr>
        </table>
        <%  if (vRetResult != null && vRetResult.size() > 0) { %>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr><td width="50%">&nbsp;</td>
            <td width="50%"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
                to print page</font></div></td>
</tr>
</table>

        <table width="100%" border="0" cellpadding="1"  class="thinborder" cellspacing="0">
          <tr bgcolor="#666666"> 
            <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
              OF OFFENSE(S)</strong></font></td>
          </tr>
          <tr> 
            <td width="19%"  class="thinborder"> <p align="center"><font size="1"><strong> OFFENSE<br>
            </strong></font></p></td>
            <td width="24%" align="center" class="thinborder"><font size="1"><strong>DETAIL</strong></font></td>
            <td width="16%" align="center" class="thinborder"><font size="1"><strong>DATE OF 
              OFFENSE/REPORTED</strong></font></td>
            <td width="12%" align="center" class="thinborder"><font size="1"><strong>ACTION 
              TAKEN</strong></font></td>
            <td width="15%" align="center" class="thinborder"><font size="1"><strong>EFFECTIVE DATE(S)</strong></font></td>
            <td width="6%" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
            <td width="8%" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
          </tr>
          <% for (int i=0; i < vRetResult.size(); i+=9) {%>
          <tr> 
            <td class="thinborder" height="23"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></font></td>
            <td align="center" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></font></td>
            <td align="center" class="thinborder"><font size="1">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")+ 
				WI.getStrValue((String)vRetResult.elementAt(i+7)," - " ,"","") %>
				</font>
			</td>
            <td class="thinborder">
              <% if (iAccessLevel > 1) {%>
              <a href="javascript:PrepareToEdit('<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
              <%}else{%> N/A <%}%>
            </td>
            <td class="thinborder"> 
			  <%if (iAccessLevel == 2) {%>
              <a href="javascript:DeleteRecord('<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%>')"><img src="../../../images/delete.gif" border="0"> </a>
              <%}else{%>N/A<%}%> </td>
          </tr>
          <%} // end for loop%>
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
<input type="hidden" name="print_page">
<input type="hidden" name="is_suspended"> 
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>

