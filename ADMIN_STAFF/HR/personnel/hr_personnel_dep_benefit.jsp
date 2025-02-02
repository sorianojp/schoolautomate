<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoDependent"%>
<%
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function Cancel() {
	document.form_.prepareToEdit.value = "";
	this.ReloadPage();
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
function PrepareToEdit(strIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strIndex;
	this.ReloadPage();
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
	document.form_.prepareToEdit.value='';
	ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Service Record","hr_personnel_dep_benefit.jsp");
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
														"hr_personnel_dep_benefit.jsp");
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
Vector vRetResult = null;//records current benefit/ incentive list.
Vector vDepBenefitHist = null;

Vector vEditInfo  = null;
Vector vEmpRec = null;Vector vTemp = null;

HRInfoDependent hrDEP = new HRInfoDependent();


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add,edit,delete
	if(hrDEP.operateOnDependentBenefit(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hrDEP.getErrMsg();
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
strTemp = WI.fillTextValue("emp_id");
if (strTemp.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = "Employee has no profile.";
}
//collect information to display.
if(strTemp.length() > 0) {
	vRetResult = hrDEP.operateOnDependentBenefit(dbOP, request, 5);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = hrDEP.getErrMsg();
	vDepBenefitHist = hrDEP.operateOnDependentBenefit(dbOP, request, 4);

//System.out.println(vRetResult);
//System.out.println(vDepBenefitHist);

//I have to get here the list of benefit employee can have. 
/*	if(strPrepareToEdit.compareTo("0") == 0)
		vBenefitIncentiveList = hrDEP.getListOfEligibleBenefitIncentive(dbOP, (String)vEmpRec.elementAt(0), false);
	else
		vBenefitIncentiveList = hrDEP.getListOfEligibleBenefitIncentive(dbOP, (String)vEmpRec.elementAt(0), true);
	if(vBenefitIncentiveList == null && strErrMsg == null) 
		strErrMsg = hrDEP.getErrMsg();*/
}
//get the edit information from here. 

if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);


//I have to get the edit info if edit is called. 
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrDEP.operateOnDependentBenefit(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = hrDEP.getErrMsg();
}

%>

<body bgcolor="#663300" class="bgDynamic" onLoad="document.form_.emp_id.focus()">
<form action="./hr_personnel_dep_benefit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          DEPENDENT BENEFIT PAGE ::::</strong></font></div></td>
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
        <table width="92%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr> 
            <td width="7%">&nbsp;</td>
            <td width="27%">Length of Service</td>
            <td width="66%"> <strong> <%=new hr.HRUtil().getServicePeriodLength(dbOP, (String)vEmpRec.elementAt(0))%></strong></td>
          </tr>
          <tr> 
            <td width="7%">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>BENEFIT NAME</td>
            <td><select name="allowance_index">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("allowance_index");
%>
                <%=dbOP.loadCombo("allowance_index","SUB_TYPE",
" FROM HR_INFO_BENEFIT_HIST join HR_BENEFIT_INCENTIVE on (HR_BENEFIT_INCENTIVE.benefit_index = HR_INFO_BENEFIT_HIST.allowance_index) "+
"where HR_INFO_BENEFIT_HIST.VALIDITY_DATE_TO is null and HR_INFO_BENEFIT_HIST.is_valid=1 and HR_INFO_BENEFIT_HIST.is_del=0 "+
"and TRANS_INDEX = 0 and user_index = "+vEmpRec.elementAt(0)+" and sub_type not like '%leave%'",strTemp,false)%> </select></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>REMARK</td>
            <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("remark");
%>			<input name="remark" type="text" size="45" maxlength="127" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Date of implementation</td>
            <td> <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("valid_fr");
%> <input name="valid_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
              <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Expire Date</td>
            <td><font size="1"> 
              <%
if(vEditInfo != null && vEditInfo.size() > 1) 
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("valid_to");
strTemp = WI.getStrValue(strTemp);
%>
              <input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              (for current Service Record leave inclusive date to empty.)</font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td width="7%">&nbsp;</td>
            <td colspan="2"> <div align="left"> 
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("0") == 0){%>
                <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{ %>
                <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> 
                <% }
}%>
                <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font></div></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2" valign="bottom"><div align="right"><img src="../../../images/print.gif"  border="0"><font size="1">click 
                to print Service Record</font></div></td>
          </tr>
        </table>
 
<%if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" bgcolor="#000000">
          <tr bgcolor="#666666"> 
            <td><div align="center"><strong><font color="#FFFFFF"><strong>DEPENDENT 
                - CURRENT BENEFIT</strong></font></strong></div></td>
          </tr>
        </table>
        <table width="98%" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#0000FF">
			<tr bgcolor="#ffffff"> 
			  
            <td width="20%" height="20"><font size="1"><strong>BENEFIT</strong></font></td>
			  
            <td width="30%"><strong><font size="1">REMARK</font></strong></td>
			  <td width="20%"><font size="1"><strong><font size="1">DATE RANGE</font></strong></font></td>
			  <td width="15%"><font size="1"><b>EDIT</b></font></td>
			  <td width="15%"><font size="1"><b>DELETE</b></font></td>
			</tr>
			<%  for (int i = 0; i < vRetResult.size(); i += 12) {%>
			<tr bgcolor="#FFFFFF"> 
			  <td><%=(String)vRetResult.elementAt(i + 8)%></td>
			  <td><%=WI.getStrValue(vRetResult.elementAt(i + 9))%></td>
			  <td><%=(String)vRetResult.elementAt(i + 10)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 11)," - ","","")%></td>
			  <td><%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'> 
				<img src="../../../images/edit.gif" border="0"></a> <%}%> </td>
			  <td> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'> 
				<img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
			</tr>
			<% } // end for loop %>
        </table>

<%}//end of if(vRetResult is not null) 

//show the history here. 
if (vDepBenefitHist != null && vDepBenefitHist.size() > 0) {%>
        <table width="98%" border="0" align="center" cellpadding="3" cellspacing="1" bgcolor="#FF0000">
          <tr bgcolor="#cccccc"> 
            <td><div align="center"><strong><font color="#0000FF"><strong>DEPENDENT 
                BENEFIT HISTORY LIST</strong></font></strong></div></td>
          </tr>
        </table>
        <table width="98%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000" align="center">
			<tr bgcolor="#ffffff"> 
			  <td width="20%" height="20"><font size="1"><strong>BENEFIT</strong></font></td>
			  
            <td width="30%"><strong><font size="1">REMARK</font></strong></td>
			  <td width="20%"><font size="1"><strong><font size="1">DATE RANGE</font></strong></font></td>
			  <td width="15%"><font size="1"><b>DELETE</b></font></td>
			</tr>
			<%  for (int i = 0; i < vDepBenefitHist.size(); i += 12) {%>
			<tr bgcolor="#FFFFFF"> 
			  <td><%=(String)vDepBenefitHist.elementAt(i + 8)%></td>
			  <td><%=WI.getStrValue(vDepBenefitHist.elementAt(i + 9))%></td>
			  <td><%=(String)vDepBenefitHist.elementAt(i + 10)%><%=WI.getStrValue((String)vDepBenefitHist.elementAt(i + 11)," - ","","")%></td>
			  <td> <% if (iAccessLevel == 2){%> <a href='javascript:PageAction("<%=(String)vDepBenefitHist.elementAt(i)%>","0");'> 
				<img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
			</tr>
			<% } // end for loop %>
		  </table>
<%}//end of if(vRetResult is not null) %>





      </td>
    </tr>
  </table>
<%}//if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1 -- most outer loop.%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" value="<%=strPrepareToEdit%>" name="prepareToEdit">
<input type="hidden" name="dependent_index" value="<%=WI.fillTextValue("dependent_index")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
