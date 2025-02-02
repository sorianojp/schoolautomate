<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction,payroll.PRMiscEarnings" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./post_earnings.jsp?emp_id="+document.form_.emp_id.value;
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function focusID() {
	document.form_.emp_id.focus();
}
function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

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
function updatePreload(){	
	var loadPg = "./earnings_preload_mgmt.jsp?opner_form_name=form_&opner_form_field=earning_index"+
				 "&opner_form_field_value="+document.form_.earning_index.value;
	var win=window.open(loadPg,"updatePreload",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_earnings_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC EARNINGS-Post Earnings","post_earnings.jsp");

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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","MISC EARNINGS",request.getRemoteAddr(),
														"post_earnings.jsp");
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

//end of authenticaion code.
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
String strSchCode = dbOP.getSchoolIndex();

PRMiscDeduction prd = new PRMiscDeduction(request);
PRMiscEarnings PREarnings = new PRMiscEarnings (request);
payroll.PRConfidential prCon = new payroll.PRConfidential();

	boolean bolCheckAllowed = true;
	if(!WI.getStrValue(strSchCode).toUpperCase().startsWith("FADI"))
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);

if (WI.fillTextValue("emp_id").length() > 0) {
	if(bolCheckAllowed){
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}
	}else
	   strErrMsg = prCon.getErrMsg();
}

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strDateFr = null;
String strDateTo = null;
int iEmpIndex = 0;
int iSearchResult = 0;
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (PREarnings.operateOnMiscEarnings(dbOP,0) != null){
			strErrMsg = " Earning removed successfully ";
		}else{
			strErrMsg = PREarnings.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (PREarnings.operateOnMiscEarnings(dbOP,1) != null){
			strErrMsg = " Earning posted successfully ";
		}else{
			strErrMsg = PREarnings.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (PREarnings.operateOnMiscEarnings(dbOP,2) != null){
			strErrMsg = " Earning updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = PREarnings.getErrMsg();
		}
	}
}

	if (WI.fillTextValue("emp_id").length() > 0) {
		vDate = prd.getSalaryPeriodInfo(dbOP,WI.getTodaysDate());
			if(vDate != null && vDate.size() > 0){
			  strDateTo = (String)vDate.elementAt(1);
			}else{
			  strDateTo = "";
			}
		vRetResult = PREarnings.operateOnMiscEarnings(dbOP,4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = PREarnings.getErrMsg();
		else
			iSearchResult = PREarnings.getSearchCount();
		vEmpList = prd.getEmployeesList(dbOP);
	}


Vector vInfoDetail = null;
if (strPrepareToEdit.length() > 0){
	vInfoDetail = PREarnings.operateOnMiscEarnings(dbOP,3);
	if (vInfoDetail == null)
		strErrMsg = prd.getErrMsg();
}

boolean bolViewOnly = false;
if(WI.fillTextValue("view").length() > 0)
	bolViewOnly = true;
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form action="post_earnings.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        PAYROLL: MISC. EARNINGS : POST EARNINGS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <% if (vEmpList != null && vEmpList.size() > 0){%>
    <tr>
      <td height="23" colspan="5" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
	<%}// if (vEmpList != null && vEmpList.size() > 0)%>	
    <tr>
      <td height="10" colspan="5">&nbsp;&nbsp;<strong> <font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr>
      <td width="50">&nbsp;</td>
      <td width="244">Employee ID :
      <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">      </td>
      <%if(!bolViewOnly){%>
      <td width="64" height="10"><a href="javascript:OpenSearch()"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <%}%>
      <td width="397" colspan="2"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
      <label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="5%" height="28">&nbsp;</td>
      <td width="45%">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="50%" height="28">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong> </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%>
        </strong></td>
      <td height="29">Employment Status :<strong><%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(!bolViewOnly){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="29">&nbsp;</td>
      <td width="19%" height="29">Earning Name</td>
	    <%
	  	if(vInfoDetail!=null) 
			strTemp= (String)vInfoDetail.elementAt(8);
		else 
			strTemp= WI.fillTextValue("earning_index");
	  %>
      <td width="78%">
	  <select name="earning_index">
          <option value="">Select earning Name</option>
          <%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded order by earn_ded_name",strTemp,false)%>
      </select>
			<%if(iAccessLevel > 1){%>
      <!--
			<a href='javascript:viewList("preload_earn_ded","earn_ded_index","earn_ded_name","MISCELLANEOUS EARNINGS");'><img src="../../../images/update.gif" border="0" ></a>
			-->
			<a href='javascript:updatePreload();'><img src="../../../images/update.gif" border="0" ></a><font size="1">clickto add to the list miscellaneous earnings </font>
			<%}%>			</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Release date</td>
        <%	if(vInfoDetail!=null)
				strTemp = (String)vInfoDetail.elementAt(2);
			else
				strTemp= WI.fillTextValue("release_date");

			if(strTemp.trim().length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
      <td height="29"><strong>
        <input name="release_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.release_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a>
      </strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Amount<strong> </strong></td>
      <%if(vInfoDetail!=null) 
	  		strTemp =(String)vInfoDetail.elementAt(3);
		else 
			strTemp= WI.fillTextValue("amount");%>
      <td height="29"><strong>
        <input  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'"  name="amount" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </strong></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Remarks</td>
        <% if(vInfoDetail!=null) 
			strTemp= (String)vInfoDetail.elementAt(7);
		  else 
		  	strTemp= WI.fillTextValue("remarks");
		%>
      <td height="10"><strong>
        <input  name="remarks" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="128">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <%
				if(vInfoDetail!=null) 
					strTemp= (String)vInfoDetail.elementAt(9);
				else 
					strTemp = WI.fillTextValue("is_taxable");				
				if(strTemp.equals("0"))
					strTemp = " checked";
				else
					strTemp =" ";
			%>
      <td height="23" colspan="2"><input type="checkbox" value="0" name="is_taxable" <%=strTemp%>>
        Earning is non taxable</td>
    </tr>
    
<%if (iAccessLevel > 1) { //if iAccessLevel > 1%>
	<tr>
	  <td height="18">&nbsp;</td>
	  <td height="18" colspan="2">&nbsp;</td>
	  </tr>
	<tr>
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2"><div align="center">
<%if (vInfoDetail == null) {%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
          to add</font>
          <%}else{%>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
          to save changes</font>
          <%}%>
          <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1" face="Verdana, Arial, Helvetica, sans-serif">click to
          cancel or go previous</font>

        </div></td>
    </tr>
<%} //end iAccessLevel > 1%>
  </table>
<%}//end if bolIsView is false..

if (vRetResult != null &&  vRetResult.size() > 0) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a>
          click to print</font></div></td>
    </tr>
    <%
		int iPageCount = iSearchResult/PREarnings.defSearchSize;		
		if(iSearchResult % PREarnings.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2" align="right">Jump To page:
        <select name="jumpto" onChange="ReloadPage();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select></td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST
          OF POSTED MISCELLANEOUS EARNINGS</strong></td>
    </tr>
    <tr>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">EARNING NAME</font></strong></td>
      <td width="12%" height="28" align="center" class="thinborder"><font size="1"><strong>RELEASE DATE</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>RECEIVABLE BALANCE</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
      <%if(!bolViewOnly){%>
      <td colspan="2" align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
 <%}%>
    </tr>
    <% for (int i = 0; i < vRetResult.size(); i+=15){
	if(vRetResult.elementAt(i + 6) != null && ((String)vRetResult.elementAt(i + 6)).equals("1"))
		strTDColor = "bgcolor=#DDDDDD";
	else
		strTDColor = "";
	%>
    <tr <%=strTDColor%>>
      <td height="25" valign="top" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td valign="top" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+3);
	  %>
      <td align="right" valign="top" class="thinborder"><font size="1"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</font></td>
	  <%
	  	strTemp = (String)vRetResult.elementAt(i+4);
	  %>	  
	  <td align="right" valign="top" class="thinborder"><font size="1"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</font></td>
      <td width="12%" align="center" valign="top" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td width="23%" valign="top" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"")%></font></td>
      <%if(!bolViewOnly){%>
      <td width="7%" class="thinborder">
	  <% if (iAccessLevel > 1 && strTDColor.length() == 0){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" ></a>
	  <%}else{%> N/A <%}%>	  </td>

      <td width="8%" class="thinborder">
	  <div align="right">
	  <%if (iAccessLevel==2 && strTDColor.length() == 0) {%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0" ></a>
	  <%}else{%>
	  N/A
	  <%}%>
	  </div></td>
<%}%>
    </tr>
    <%} //end for loop%>
  </table>

<% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">

<%if(bolViewOnly){%>
<input type="hidden" name="view" value="1">
<%}%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
