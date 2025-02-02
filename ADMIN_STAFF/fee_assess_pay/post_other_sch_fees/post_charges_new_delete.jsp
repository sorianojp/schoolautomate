
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
table.thinborder{
	border-top : solid  1px #BB0004;
	border-right : solid 1px #BB0004;
}

TD.thinborder {
    border-left: solid 1px #BB0004;
    border-bottom: solid 1px #BB0004;
} 
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	if(document.form_.delete_ && document.form_.delete_.checked) {
		if(document.form_.date_posted_fr.length == 0) {
			alert("Please enter date Posted from information");
			document.form_.delete_.checked = false;
			document.form_.date_posted_to.value = '';
			return;
		}
		document.form_.date_posted_to.value = '';
	}
	document.form_.show_list.value = "";
	document.form_.page_action.value = "";	
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.show_list.value = "1";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function SelALL() {
	var strIsChecked = false;
	if(document.form_.sel_all.checked)
		strIsChecked = true;
	var iMaxDisp = document.form_.max_disp.value;
		
	var vObj;
	for(i = 0; i < eval(iMaxDisp); ++i) {
		eval('vObj=document.form_.payable_i'+i);
		if(!vObj)
			continue;
		if(strIsChecked)
			vObj.checked = true;
		else	
			vObj.checked =false;
	}
}
function DeleteCalled() {
	if(!confirm("Are you sure you want to remove the posted charge permanently?"))
		return;
		
	document.form_.del_button.disabled=true;
		
	document.form_.show_list.value='1';
	document.form_.page_action.value = '0';
	document.form_.submit();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		var objCOAInput = document.getElementById("coa_info");
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2) {
			objCOAInput.innerHTML = "";
			return;
		}	
		
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

/** ajax update oc **/
function ajaxUpdatePostCharge(strOCIndex,strLevel) {
	var newVal = prompt('Please enter new amount','');
	if(newVal == null || newVal == '')
		return;
	
	var objCOAInput = document.getElementById(strLevel);

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=98&pi="+strOCIndex+"&new_val="+newVal;
	
	this.processRequest(strURL);


}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_new_delete.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
String strUserId = (String)request.getSession(false).getAttribute("userId");
if(strUserId == null)
	strUserId = "0";
	
CommonUtil comUtil = new CommonUtil();
boolean bolGrantAll = false;
if(comUtil.IsSuperUser(dbOP,strUserId))
	bolGrantAll = true;	//grant all ;-)
Vector vAuthList = null;
if(!bolGrantAll) {
	vAuthList = comUtil.getAuthModSubModNameList(dbOP, strUserId, "Fee Assessment & Payments");
	if(vAuthList == null)
		vAuthList = new Vector();
	else if( ((String)vAuthList.elementAt(0)).compareTo("#ALL#") == 0) 
		bolGrantAll = true;
}

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_new_delete.jsp");
if(!bolGrantAll) {
	if(comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"), "Fee Assessment & Payments",
		"Post Charge - Unrestricted",request.getRemoteAddr(), null) > 0)
		bolGrantAll = true;
//insert into sub_module (module_index, sub_mod_name) values (44,'Post Charge - Unrestricted')
}
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

Vector vRetResult = null;
java.sql.ResultSet rs = null; 

enrollment.FAFeePost feePost  = new enrollment.FAFeePost();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(feePost.operateOnViewDelete(dbOP, request, Integer.parseInt(strTemp)) != null)		
		strErrMsg = "Delete successful.";
	else	
		strErrMsg = feePost.getErrMsg();	
}

if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = feePost.operateOnViewDelete(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = feePost.getErrMsg();
}

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

String strSYFrom = null;
String strSYTo   = null;
String strSemester = null;

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;
%>
<form name="form_" action="./post_charges_new_delete.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          Post Other School Fees Page - View/Delete ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" width="2%">&nbsp;</td>
      <td width="14%" >School Year</td>
      <td width="34%"> 
<%
strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strSYTo = Integer.toString(Integer.parseInt(strSYFrom) + 1);
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
	  <select name="semester">
<%
strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="0"<%=strErrMsg%>>Summer</option>
<%if(strSemester.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%if(strSemester.compareTo("2") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%if(strSemester.compareTo("3") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select></td>
      <td width="50%" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();"> Is Basic
	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Date Posted </td>
      <td><input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Fee Name </td>
      <td colspan="2">
	  <select name="fee_type" style="width:500px">
	  	<option value=""></option>
		<%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name"," from fa_oth_sch_fee where is_valid=1 order by fa_oth_sch_fee.fee_name asc",WI.fillTextValue("fee_type"), false)%>      
	  </select></td>
    </tr>
<%if(bolIsBasic){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Grade Level</td>
      <td colspan="2">
	  	<select name="g_level">
			<option value="">ALL</option>
				<%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",strTemp,false)%> 
		</select>
		</td>
    </tr>
<%}else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2"><select name="course_index" style="width:500px;">
        <option value=""></option>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_name asc",
		  		request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year Level </td>
      <td><select name="year_level">
        <option value=""></option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() == 0) 
	strTemp = "-1";
int iDefYr = Integer.parseInt(strTemp);
	for(int i = 1; i < 7; ++i) {
		if(iDefYr == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
        <option value="<%=i%>"<%=strTemp%> ><%=i%></option>
        <%}%>
      </select>      </td>
      <td>&nbsp;</td>
    </tr>
<%}%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Subject  </td>
      <td colspan="2">
        <select name="sub_index" style="width:500px;">
          <option value=""></option>
<%
strTemp = " from subject join fa_stud_payable on (fa_stud_payable.requested_sub_index=subject.sub_index) where fa_stud_payable.is_valid = 1 and sy_from = "+
			strSYFrom+" and semester = "+strSemester+" order by sub_code ";
%>
          <%=dbOP.loadCombo("distinct SUB_INDEX","SUB_CODE, sub_name",strTemp,WI.fillTextValue("sub_index") , false)%>
        </select>
        <input name="123452222" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='';document.form_.page_action.value = ''" value="Reload Requested Subject List">      </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Student ID </td>
      <td colspan="2"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
      class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
      onChange = "javascript:HideSaveButton()" onKeyUp="AjaxMapName('1');">
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute"></label>
	  
	  </td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td><input name="1234522" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value = ''" value="Show Student list"></td>
      <td align="right"><input name="12345222" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='2';document.form_.page_action.value = ''" value="Show Complete Result"></td>
    </tr>
</table>
<!--- Ready now to have filter.. -->
<%if(vRetResult != null && vRetResult.size() > 0 ) {
boolean bolIsViewAll = false;
if(WI.fillTextValue("show_list").equals("2")) 
	bolIsViewAll = true;

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>::: List of Student to Post Charge ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="10" style="font-size:10px; font-weight:bold">&nbsp;
	  Total Display : <%=vRetResult.size()/13%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Student ID</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="20%" class="thinborder">Student Name</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder"><%if(bolIsBasic){%>Grade Level<%}else{%>Course<%}%></td>
      <td style="font-size:10px; font-weight:bold" align="center" width="8%" class="thinborder">Date Posted </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="8%" class="thinborder">Posted By </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="20%" class="thinborder">Fee Name </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">SY-Term</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Posted for Subject? </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Amount</td>
<%if(!bolIsViewAll || bolGrantAll) {%>
      <td style="font-size:10px; font-weight:bold" align="center" width="4%" class="thinborder">Select <br>
        <input type="checkbox" name="sel_all" onClick="SelALL();" value="checked" <%=WI.fillTextValue("sel_all")%>></td>
<%}%>
    </tr>
    <%for(int i = 0; i < vRetResult.size(); i += 13){%>
		<tr>
		  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
		  <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 5)%></td>
		  <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"Auto Posted")%></td>
		  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 8)%></td>
		  <td class="thinborder" align="center"><%=(String)vRetResult.elementAt(i + 11)%> - <%=(String)vRetResult.elementAt(i + 12)%></td>
		  <td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"&nbsp;")%></td>
		  <td class="thinborder" align="center" <%if(!bolIsViewAll || bolGrantAll) {%>onDblClick="ajaxUpdatePostCharge('<%=vRetResult.elementAt(i)%>','_<%=vRetResult.elementAt(i)%>')"<%}%>><label id="_<%=vRetResult.elementAt(i)%>"><%=(String)vRetResult.elementAt(i + 10)%></label></td>
<%if(!bolIsViewAll || bolGrantAll) {%>
		  <td class="thinborder" align="center">&nbsp;<input type="checkbox" name="payable_i<%=i/13%>" value="<%=vRetResult.elementAt(i)%>"></td>
<%}%>
		</tr>
	<%}%>
  </table>
  <input type="hidden" name="max_disp" value="<%=vRetResult.size()/13%>">
<%if(!bolIsViewAll || bolGrantAll) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center"><input name="del_button" id="del_button" type="button" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="DeleteCalled();" value="Delete Post charges"></td>
    </tr>
  </table>
<%}%>
  
<%}//if vRetResult is not null%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="5" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_page">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="page_action">
 <input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
