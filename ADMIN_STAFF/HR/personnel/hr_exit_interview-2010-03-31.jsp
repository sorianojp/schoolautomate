<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoExitInterview,hr.HRInfoServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

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
	this.SubmitOnce("staff_profile");
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

function DeleteRecord(strInfoIndex){
	document.staff_profile.info_index.value=strInfoIndex;
	document.staff_profile.page_action.value="0";
	this.SubmitOnce("staff_profile");	
}

function PrepareToEdit(strInfoIndex){
	document.staff_profile.info_index.value =strInfoIndex;
	document.staff_profile.prepareToEdit.value="1";
	this.SubmitOnce("staff_profile");
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(strEmpID){
	location = "./hr_exit_interview.jsp";
}

function FocusID() {
	document.staff_profile.emp_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddInterviewer()
{

	if (document.staff_profile.supervisor.selectedIndex == 0) {
		alert (" Please select interviewer");
		return ;
	}else{
	
		document.staff_profile.add_fee.value = "1";
		document.staff_profile.list_count.value = ++document.staff_profile.list_count.value;
		document.staff_profile.interviewer_name.value = 
			document.staff_profile.supervisor[document.staff_profile.supervisor.selectedIndex].text;
	}
	
	
	document.staff_profile.page_action.value="";
	this.SubmitOnce("staff_profile");
}

function RemoveFeeName(removeIndex)
{
	document.staff_profile.remove_index.value = removeIndex;
	document.staff_profile.page_action.value="";
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


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_exit_interview.jsp");

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
														"hr_exit_interview.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
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
Vector vEditInfo = null;
Vector vInterviewers = null;

HRInfoExitInterview hrPx = new HRInfoExitInterview();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
boolean bolSetEdit = false;
String strFirstEntry = WI.fillTextValue("first_entry");

if (strFirstEntry.length() == 0) 
	strFirstEntry = "0";

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));

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

	if (iAction == 1 || iAction  == 2 || iAction==0)
	vRetResult = hrPx.operateOnExitInterview(dbOP,request,iAction);
	
	switch(iAction){
		case 0:{
			if (vRetResult != null)
				strErrMsg = " Employee exit interview record removed successfully.";
			else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
		case 1:{ // add Record
			if (vRetResult != null)
				strErrMsg = " Employee exit interview record added successfully.";
			else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
		case 2:{ //  edit record
			if (vRetResult != null){
				strErrMsg = " Employee exit interview record edited successfully.";
				strPrepareToEdit = "";
				strFirstEntry = "0";
			}else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
	} //end switch
}
if (strPrepareToEdit.compareTo("1")  == 0){

	vEditInfo = hrPx.operateOnExitInterview(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = hrPx.getErrMsg();

}

vRetResult = hrPx.operateOnExitInterview(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg= hrPx.getErrMsg();
}

	int iListCount = 0;
	String[]  astrNature = {"Resignation", "Deceased", "Retirement", "On Leave", "Others", "Termination", "Non Renewal of Contract"};
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_exit_interview.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          EXIT INTERVIEW RECORD ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
	  </td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
      
	  <%if(strSchCode.startsWith("LHS")){//update the list of personnel involved in Exit Interview.. %>
				<a href="javascript:UpdateList();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update notify list</font>
	  <%}%>
	  
	  <label id="coa_info"></label>
			</td>
    </tr>
  </table>

  <% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%"><hr size="1"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+
			  					"\" width=150 height=150 align=\"right\" border=\"1\">";%>
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
        <table width="90%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td width="26%">Date Request Tendered</td>
            <% if (vEditInfo != null)  strTemp =  WI.getStrValue((String)vEditInfo.elementAt(2));
			else strTemp = WI.fillTextValue("tender"); %>
            <td width="74%"> <input name="tender" type="text" value="<%=strTemp%>" size="15" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AllowOnlyIntegerExtn('staff_profile','tender','/')"> <a href="javascript:show_calendar('staff_profile.tender');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
            &nbsp;</td>
          </tr>
          <tr> 
            <td>Effective Separation </td>
            <% if (vEditInfo != null)  strTemp =  WI.getStrValue((String)vEditInfo.elementAt(3));
			else strTemp = WI.fillTextValue("effective"); %>
            <td><a href="javascript:show_calendar('staff_profile.effective');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
              &nbsp;
              <input name="effective" type="text" value="<%=strTemp%>" size="15" 
			onKeyUp="AllowOnlyIntegerExtn('staff_profile','effective','/')" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> <input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('staff_profile.starts_with2','staff_profile.supervisor',true);"> 
              <font size="1"> interviewer name</font></td>
          </tr>

          <tr>
            <td height="15" colspan="2"><table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
              <tr>
                <td width="26%">Interviewed by </td>
                <td colspan="2"><% 
				if (vEditInfo != null) 
					strTemp = "";
				else
					strTemp = WI.fillTextValue("supervisor");
	
	Vector vTemp = new HRInfoServiceRecord().getSupervisorDetail(dbOP,request,(String)vEmpRec.elementAt(0),strTemp, strTemp3);
%>
                    <select name="supervisor">
                      <option value="">- </option>
                      <%
if(vTemp != null && vTemp.size() > 0){
	for(int i = 0; i < vTemp.size(); i += 2) {
		if(strTemp.compareTo((String)vTemp.elementAt(i)) == 0){%>
                      <option value="<%=(String)vTemp.elementAt(i)%>" selected> <%=(String)vTemp.elementAt(i + 1)%></option>
                      <%}else{%>
                      <option value="<%=(String)vTemp.elementAt(i)%>"> <%=(String)vTemp.elementAt(i + 1)%></option>
                      <%}
	}
}%>
                    </select>
                    <font size="1">(select if applicable) </font></td>
              </tr>
	<% if (vEditInfo != null) 
			strTemp = "";
	   else 
			strTemp = WI.fillTextValue("date_interview");
	%>
              <tr>
                <td height="15">Date of Interview </td>
                <td width="25%" height="15"><input name="date_interview" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUP="AllowOnlyIntegerExtn('staff_profile','date_interview','/')" value="<%=strTemp%>" size="15" >
                  <a href="javascript:show_calendar('staff_profile.date_interview');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
                <td width="49%"><a href="javascript:AddInterviewer();"><img src="../../../images/add.gif" border="0"></a><font size="1">Click
                  to add  interviewer</font></td>
              </tr>
		<%if(strSchCode.startsWith("LHS")){%>
		<tr>
			<td height="25">Exit Interview Form: </td>
			<td colspan="2">
			<%if(!hrl.hasNotSentExitIntvForm(dbOP, (String)vEmpRec.elementAt(0))){
				strExitIntvIndex = hrl.getExitIntvIndex(dbOP, (String)vEmpRec.elementAt(0));
				if(hrl.isExitInterviewDataCompleted(dbOP, request, strExitIntvIndex)
					|| !hrl.isOnNotifyList(dbOP, (String)request.getSession(false).getAttribute("userIndex"), 0)){%>
					<a href="javascript:ViewExitIntvForm('<%=strExitIntvIndex%>');">
						<img src="../../../images/view.gif" border="0"></a>
				<%}else{%>
					<a href="javascript:UpdateExitIntvForm('<%=strExitIntvIndex%>');">
						<img src="../../../images/update.gif" border="0"></a>
				<%}
				}else{%>N/A<%}%></td>
		</tr>
		<tr>
			<td height="25">Checklist Status: </td>
			<td colspan="2" valign="middle">
				<%
					strTemp = hrl.getChecklistStatus(dbOP, (String)vEmpRec.elementAt(0));
				%>
				<%=strTemp%>
				
				<%if(strTemp.equals("Pending") && hrl.isPartOfNotifyChecklist(dbOP, (String)request.getSession(false).getAttribute("userIndex"))){
					strTemp = hrl.getChecklistIndex(dbOP, request, (String)vEmpRec.elementAt(0));
				%>
				
					<a href="javascript:UpdateExitIntvChecklist('<%=strTemp%>');">
						<img src="../../../images/update.gif" border="0"></a>
				<%}%></td>
		</tr>
		<%}//end of LHS Exit Interview Updates.. %>
              <tr>
                <td height="15" colspan="3">
<% int iCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("list_count"),"0"));
	if (vEditInfo != null)
		vInterviewers = (Vector)vEditInfo.elementAt(7);
		
	if (vInterviewers != null && vInterviewers.size() > 0 && strFirstEntry.equals("0")){
		// set iCount on 1st Entry only.. 
		iCount = 	vInterviewers.size() / 3;
	}
	

	
if (iCount > 0) { %> 
				
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="3" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST OF EXIT INTERVIEWERS</strong></div></td>
    </tr>
    <tr bgcolor="#33CCFF">
      <td width="60%" height="21" align="center" class="thinborder"><strong>NAME OF INTERVIEWER </strong></td>
      <td width="26%" align="center" class="thinborder"><strong>DATE INTERVIEW </strong></td>
      <td width="14%" class="thinborder"><strong>REMOVE</strong></td>
    </tr>
    <%
strErrMsg = null;
String strInteviewerIndex = null;//this is fee already calculated.
int iRemoveIndex    = Integer.parseInt(WI.getStrValue(WI.fillTextValue("remove_index"),"-1"));

String strIntvwrIndex     = null;
String strDateIntvw = null;

for(int i=0; i<iCount; ++i)
{
	if(i == iRemoveIndex)
		continue;

		if( i == iCount -1 && WI.fillTextValue("add_fee").length() > 0) {
			strTemp          = WI.fillTextValue("interviewer_name");
			strIntvwrIndex   = WI.fillTextValue("supervisor");
			strDateIntvw      = WI.fillTextValue("date_interview");
		}
		else {
			strTemp          = WI.fillTextValue("interviewer_name"+i); 
			strIntvwrIndex   = WI.fillTextValue("supervisor"+i);
			strDateIntvw	 = WI.fillTextValue("date_interview"+i);
		}
	
		if (strFirstEntry.equals("0") && vInterviewers != null && vInterviewers.size() > 0){
			// overwrite entries;
			strTemp = (String)vInterviewers.elementAt(i*3);
			strIntvwrIndex = (String)vInterviewers.elementAt(i*3 + 2);
			strDateIntvw = (String)vInterviewers.elementAt(i*3 + 1);
		}
	
	%>
    <input type="hidden" name="interviewer_name<%=iListCount%>" value="<%=strTemp%>">
	<input type="hidden" name="supervisor<%=iListCount%>" value="<%=strIntvwrIndex%>">
    <input type="hidden" name="date_interview<%=iListCount%>" value="<%=WI.getStrValue(strDateIntvw)%>">
	
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%> </td>
      <td class="thinborder">&nbsp;&nbsp;<%=WI.getStrValue(strDateIntvw)%></td>
      <td class="thinborder"><a href='javascript:RemoveFeeName("<%=iListCount%>");'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%
	//add here to list, it is safe now.
	++iListCount;
}
	if (strFirstEntry.equals("0") && vInterviewers != null && vInterviewers.size() > 0){
		strFirstEntry = "1";	
	}

%>
  </table>
  
 <%} // end if iCount > 0 %>    </td>
                </tr>
            </table></td>
          </tr>
          <tr>
            <td height="15">&nbsp;</td>
            <td height="15">&nbsp;</td>
          </tr>
        </table>
        <table width="75%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#F7F7F7" class="thinborderall">
          <tr> 
            <td valign="bottom">&nbsp;</td>
            <td colspan="2" valign="bottom">Nature of Separation </td>
            <td valign="bottom">&nbsp;</td>
          </tr>
          <tr>
            <td valign="bottom">&nbsp;</td>
            <td colspan="2" valign="bottom">
		<% if (vEditInfo != null) 
				strTemp = (String)vRetResult.elementAt(0);
		   else 
		   		strTemp =  WI.fillTextValue("nature_separation");%>
              <select name="nature_separation">
				<%for (int i = 0; i < astrNature.length; i++){
						if (Integer.toString(i).equals(WI.getStrValue(strTemp))){ %>
				 <option value="<%=i%>" selected><%=astrNature[i]%> </option>
				 <%}else{%> 
				 <option value="<%=i%>"><%=astrNature[i]%> </option>
				 <%}
				 }%> 
              </select>
              </td>
            <td valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td width="1%" valign="bottom">&nbsp;</td>
            <td width="97%" colspan="2" valign="bottom">Reason for Separation <br> 
              <% if (vEditInfo != null) strTemp = (String)vRetResult.elementAt(0);
		   else strTemp = WI.fillTextValue("reason");%> <select name="reason">
                <%=dbOP.loadCombo("REASON_INDEX","EXIT_INTV_REASON"," FROM HR_PRELOAD_EXIT_INTV_REASON ",strTemp,false)%> </select> <strong> <a href='javascript:viewList("HR_PRELOAD_EXIT_INTV_REASON","REASON_INDEX","EXIT_INTV_REASON","MAJOR REASON",
			  "HR_INFO_RESIGNATION","REASON_INDEX", "and HR_INFO_RESIGNATION.is_del = 0 and HR_INFO_RESIGNATION.is_valid = 1","","reason")'><img src="../../../images/update.gif" border="0"></a> 
              </strong><font size="1">click to update list</font> </td>
            <td width="1%" valign="bottom">&nbsp;</td>
          </tr>
          <tr valign="middle"> 
            <td></td>
            <td colspan="2"></td>
            <td></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <% if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(5);
			   else strTemp = WI.fillTextValue("detail"); %>
            <td colspan="2"><p><strong>Remarks</strong>:<br>
                <textarea name="detail" cols="60" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" class="textbox"><%=WI.getStrValue(strTemp)%></textarea>
              </p></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>
        <table width="92%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="15" colspan="2" valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2" align="center"> 
              <% if (iAccessLevel > 1){
					if (vEditInfo == null) { %>              <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
              <font size="1">click to save entries</font> 
              <%}else{%>              <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
              <font size="1">click to save changes</font> 
              <%} // end if else vEditInfo != null%>
              <font size="1">&nbsp;<a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a>click 
              to cancel and clear entries</font> 
              <%} // if iAccessLevel > 1%>            </td>
          </tr>
        </table>
        <p>&nbsp;</p></td>
    </tr>
  </table>
<% 
if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EDF0FA"> 
      <td width="13%" height="25" align="center"  class="thinborder"><strong><font size="1">DATE TENDER</font></strong></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">EFFECTIVE SEPARATION </font></strong></div></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">INTERVIEWED BY</font></strong></td>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">REASON</font></strong></td>
      <td width="23%" align="center" class="thinborder"><strong><font size="1">DETAIL</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">EDIT</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
	<% 
	
//		System.out.println(vRetResult);
	strTemp = "";
	int k = 0;
	for (int i = 0; i < vRetResult.size();i+=8){
		vInterviewers = (Vector)vRetResult.elementAt(i+7);
		if ( vInterviewers != null && vInterviewers.size() > 0) {
			for (k = 0; k < vInterviewers.size();  k+=3){
				if (strTemp.length() == 0) 
					strTemp = (String)vInterviewers.elementAt(k) + 
						WI.getStrValue((String)vInterviewers.elementAt(k+1)," (",	")", "");
				else
					strTemp += " <br> " + (String)vInterviewers.elementAt(k) + 
						WI.getStrValue((String)vInterviewers.elementAt(k+1)," (",	")", "");
			}
		}

	%>
    <tr> 
      <td class="thinborder" height="25">
	  	<font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%>	    </font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp")%></font></td>
      <td class="thinborder">
	  <% if (iAccessLevel > 1){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+6)%>')">
	  <img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>
		N/A	  
	  <%}%></td>
      <td class="thinborder">
	  <% if (iAccessLevel == 2){%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+6)%>')"><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%> N/A <%}%>	  </td>
    </tr>
	<%} //end for loop%>
  </table>
  <%} // if vRetResult != null
  } // vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="setEdit" value="<%%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="first_entry" value="<%=strFirstEntry%>">

	
	<input type="hidden" name="list_count" value="<%=iListCount%>">	
	<input type="hidden" name="add_fee">	
	<input type="hidden" name="remove_index">
	<input type="hidden" name="interviewer_name">
	
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
