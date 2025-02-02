<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut,
																eDTR.TempDTR" %>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Approve Temp DTR</title>
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
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
	function ReloadPage(){
		document.dtr_op.submit();
	}
	
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
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
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSave() {
	var maxDisp = document.dtr_op.recordcount.value;
	//unselect if it is unchecked.
 	if(!document.dtr_op.selAllSave.checked) {
		for(var i = 1; i <= maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i <= maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}
function SaveData() {
	document.dtr_op.page_action.value = "1";
	this.SubmitOnce('dtr_op');
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","approve_temp_dtr.jsp");

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
														"eDaily Time Record","DTR OPERATIONS-APPROVE DTR",request.getRemoteAddr(),
														"approve_temp_dtr.jsp");
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

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////

TempDTR tempDTR = new TempDTR();
Vector vRetResult = null;
String[] astrEditStatus = {"Delete Request", "Save New", "Edit Existing"};
int iPageAction  = 0;
Vector vUsers = null;
String strTempIndex = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(tempDTR.operateOnTempDTRApproval(dbOP, request, 1) == null)
		strErrMsg = tempDTR.getErrMsg();
	else
		strErrMsg = "Operation successful";
}

vRetResult = tempDTR.operateOnTempDTRApproval(dbOP, request, 4);
if(vRetResult == null){
	if(strErrMsg == null)
		strErrMsg = tempDTR.getErrMsg();
	
}else{
	vUsers = (Vector) vRetResult.elementAt(0);
}
%>

<form action="./approve_temp_dtr.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - APPROVE TEMPORARY DTR PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25">Date</td>
            <td height="25">From
              <input name="date_from" type="text" size="10" maxlength="10" 
	  value="<%=WI.fillTextValue("date_from")%>" class="textbox" 
	  onKeyUp="AllowOnlyIntegerExtn('dtr_op','date_from','/');"
	  onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_from','/')">
              <a href="javascript:show_calendar('dtr_op.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to 
        &nbsp;&nbsp;
        <input name="date_to" type="text" size="10" maxlength="10" 
		value="<%=WI.fillTextValue("date_to")%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp = "AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/')">
        <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25">Enter Employee ID </td>
            <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="3%">&nbsp;</td>
            <td width="24%" height="25">Employment Type</td>
            <td width="73%" height="25">
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
              </select>            </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25"><%if(bolIsSchool){%>
            College
              <%}else{%>
              Division
              <%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25"><%=strTemp2%></td>
            <td height="25"> 
						<select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3 = WI.fillTextValue("d_index");%>
            <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> 
						</select>						</td>
          </tr>
          
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25">Status</td>
            <td height="25"><select name="status" id="status">
              <option value="1">APPROVE</option>
              <%if (WI.fillTextValue("status").equals("0")){%>
              <option value="0" selected>DISAPPROVE</option>
              <%}else{%>
              <option value="0" >DISAPPROVE</option>
              <%}%>
            </select></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td>&nbsp;</td>
            <td height="25" colspan="2"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
              <font size="1">click to display employee list to print.</font></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25" colspan="3"><hr size="1"></td>
          </tr>
  </table>
  <%
	int iIndexOf = 0;
	Long lIndex = null;
	if (vRetResult != null && vRetResult.size() > 1 && vUsers != null && vUsers.size() > 0)  {%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" align="center"><font color="#FFFFFF">
	  	<strong>LIST OF UPDATE REQUESTS </strong></font></td>
    </tr>
  </table>
	<%if(vUsers != null && vUsers.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td width="20%" height="25" align="center" class="thinborder"><strong>DAY :: TIME</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>LATE</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>TIME OUT </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UT</strong></td>
      <td width="15%" align="center" class="thinborder"><strong>TYPE</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>ENCODED BY </strong></td>
      <td width="5%" align="center" class="thinborder"><strong>SELECT ALL<br>
        <font size="1">
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
        </font></strong></td>
    </tr>
		<%
		int iCount = 0;
		for(int iUser = 0; iUser < vUsers.size(); iUser+=7){
			lIndex = (Long)vUsers.elementAt(iUser);		
		%>
    <tr >
      <td height="27" colspan="7" valign="bottom" class="thinborder">&nbsp;<%=WI.formatName((String)vUsers.elementAt(iUser+1), (String)vUsers.elementAt(iUser+2), (String)vUsers.elementAt(iUser+3), 4)%></td>
    </tr>
    <%iIndexOf = vRetResult.indexOf(lIndex);
			while(iIndexOf != -1){
			iCount++;
		%>
		<input type="hidden" name="user_<%=iCount%>" value="<%=vRetResult.remove(iIndexOf)%>">
		<%
			strTempIndex = (String)vRetResult.remove(iIndexOf); // remove temp index
			strTemp = (String) vRetResult.remove(iIndexOf); // remove timein_date
		%>
		<input type="hidden" name="temp_index_<%=iCount%>" value="<%=strTempIndex%>">
		<input type="hidden" name="timein_date_<%=iCount%>" value="<%=strTemp%>">
		<tr bgcolor="#DDDDDD">
			<%
				strTemp = WI.getStrValue((String)vRetResult.remove(iIndexOf)); // remove timein_long
			%>
      <td height="22"  class="thinborder">&nbsp;<%=strTemp%></td>
	    <%
				strTemp = WI.getStrValue((String)vRetResult.remove(iIndexOf)); // remove late_min
			%>
			<input type="hidden" name="late_val_<%=iCount%>" value="<%=strTemp%>">
			<%
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
				strTemp = ""; 
			%>
      <td  class="thinborder">&nbsp; <%=strTemp%>
        <%if (strTemp.length() > 0 && !strTemp.equals("0")){%> 
					min(s)
				<%}%>
			</td>
			<%
			strTemp = (String) vRetResult.remove(iIndexOf); // remove timeout_date
			%>
			<input type="hidden" name="timeout_date_<%=iCount%>" value="<%=strTemp%>">
			<%	
				strTemp = WI.getStrValue((String)vRetResult.remove(iIndexOf)); // remove timeout_long
			%>
	    <td  class="thinborder">&nbsp;<%=strTemp%></td>
	    <% 
			strTemp = WI.getStrValue(vRetResult.remove(iIndexOf));// ut_min
			%>
			<input type="hidden" name="ut_min_<%=iCount%>" value="<%=strTemp%>">
			<% 
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
				strTemp = ""; %>	  
			<td  class="thinborder">&nbsp; <%=strTemp%>
				<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>
					min(s)
				<%}%>			
			<%strTemp = (String)vRetResult.remove(iIndexOf);// remove wh_index%>
			<input type="hidden" name="wh_index_<%=iCount%>" value="<%=WI.getStrValue(strTemp)%>" size="4"
			readonly>
			</td>

			<%strTemp = (String)vRetResult.remove(iIndexOf);// tin tout index%>
			<input type="hidden" name="tin_tout_index_<%=iCount%>" value="<%=strTemp%>">			

			<%strTemp = (String)vRetResult.remove(iIndexOf); // remove edit_status%>
			<input type="hidden" name="edit_stat_<%=iCount%>" value="<%=strTemp%>">
      <td  class="thinborder">&nbsp;(<%=astrEditStatus[Integer.parseInt(strTemp)]%>)</td>
			<%
				strTemp = (String)vRetResult.remove(iIndexOf);// remove name of encoder
			%>
      <td  class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%
				strTemp = (String)vRetResult.remove(iIndexOf);// remove timein in long
			%>
			<input type="hidden" name="timein_<%=iCount%>" value="<%=strTemp%>">

			<%
				strTemp = (String)vRetResult.remove(iIndexOf);// remove timeout in long
			%>
			<input type="hidden" name="timeout_<%=iCount%>" value="<%=strTemp%>">

			<%strTemp = (String)vRetResult.remove(iIndexOf);// remove timeout AM_pm_set%>
			<input type="hidden" name="am_pm_set_<%=iCount%>" value="<%=strTemp%>">			
			
      <td align="center"  class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="<%=iCount%>"></td>
    </tr>
	<%
		iIndexOf = vRetResult.indexOf(lIndex);
		}// end while loop
	}// end vUsers for loop
	%>
		<input type="hidden" name="recordcount" value="<%=iCount%>">
  </table>
	<%}// end if vUsers != null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="22"><font size="1">
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
      </font><font size="1">click to save entries</font></td>
    </tr>
  </table>	
	<%}// end if vRetResult != null%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="22">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
