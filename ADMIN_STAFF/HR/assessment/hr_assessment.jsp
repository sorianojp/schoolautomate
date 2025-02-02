<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function EvalTotal(iMaxAllowedVal, iIndex){
	var vInputVal = eval('document.staff_profile.point'+iIndex+'.value');
	if( eval(vInputVal) > eval(iMaxAllowedVal)) {
		alert (" Point given should not be greater than maximum point");
		eval('document.staff_profile.point'+iIndex+'.value=0');
	}
	else if(vInputVal.length == 0) {
		eval('document.staff_profile.point'+iIndex+'.value=0');
	}
	//I have to get total points.
	var totalPt = 0;
	var maxDisp = document.staff_profile.max_disp.value;
	for(var i = 0; i < eval(maxDisp); ++i) {
		totalPt = Number(totalPt) + Number(eval('document.staff_profile.point'+i+'.value'));
	}
	document.staff_profile.g_total.value = eval(totalPt);
}
function ClearEntries() {
	var maxDisp = document.staff_profile.max_disp.value;
	for(var i = 0; i < eval(maxDisp); ++i) {
		eval('document.staff_profile.point'+i+'.value=0');
	}
	document.staff_profile.g_total.value ="0";
	document.staff_profile.comment.value = "";
}
function ReloadPage()
{
	document.staff_profile.page_action.value = "";
	this.SubmitOnce('staff_profile');
}
function AddRecord(){
	document.staff_profile.page_action.value ="1";
	this.SubmitOnce('staff_profile');
}
function DeleteRecord(){
	document.staff_profile.page_action.value ="0";
	this.SubmitOnce('staff_profile');
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
</script>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strRootPath = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment.jsp");
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

//end authorization
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vYearInfo = null;
Vector vEvalPeriod = null;
Vector vEditInfo   = null;//only if evaluation exists.

HREvaluationSheet hrES = new HREvaluationSheet();
String strPageAction = WI.fillTextValue("page_action");
if(WI.fillTextValue("criteria_index").length() > 0) {
	vYearInfo = hrES.getEvalSheetYearInfo(dbOP, WI.fillTextValue("criteria_index"));
	if(vYearInfo == null) {
		strErrMsg = hrES.getErrMsg();
	}
}
if(WI.fillTextValue("sy_from").length() > 0) {
	vEvalPeriod = hrES.operateOnEvalPeriod(dbOP, request, 4);
}

enrollment.Authentication authentication = new enrollment.Authentication();
vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
if(vEmpRec == null || vEmpRec.size() ==0) {
	strErrMsg = authentication.getErrMsg();
}
else if(WI.fillTextValue("page_action").length() > 0) {
	if(hrES.operateOnEvalPersonnelDtls(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) == null)
		strErrMsg = hrES.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}

//find if information already created. 
int iIndexEdit = 0;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("eval_period_index").length() > 0) {
	vEditInfo = hrES.operateOnEvalPersonnelDtls(dbOP, request,3);
	if(vEditInfo == null && strErrMsg == null)
		strErrMsg = hrES.getErrMsg();
}
%>
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVALUATION RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><strong><font color="#0000FF">NOTE : One evaluator 
        can't have more than one evaluation per day.</font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">Employee ID : </td>
      <td width="79%"><input value ="<%=WI.fillTextValue("emp_id")%>" name="emp_id" type="text"  class="textbox" id="emp_id"  onfocus="style.backgroundColor='#D3EBFF'" 
	  onblur="style.backgroundColor='white'" size="16" maxlength="32"  ></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Evaluation Criteria</td>
      <td><select name="criteria_index" onChange="ReloadPage();">
          <option value="" selected>Select Evaluation Criteria</option>
          <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("criteria_index"),false)%> 
        </select>
        <%strTemp = null;strErrMsg = null;
			for(int i =0; vYearInfo != null && i < vYearInfo.size(); i += 3) {
				if(((String)vYearInfo.elementAt(i + 2)).compareTo("1") == 0){
					strTemp = (String)vYearInfo.elementAt(i);
					strErrMsg = (String)vYearInfo.elementAt(i + 1);
				}
			}
			if(strTemp == null && vYearInfo != null) {
				strTemp = (String)vYearInfo.elementAt(0);
				strErrMsg = (String)vYearInfo.elementAt(1);
			}
			%> 
			<strong><font size="3"><%=WI.getStrValue(strTemp,""," - "+strErrMsg+"</font></strong><font size=1>, (Active evaluation period)","")%></font></strong> 
			<input type="hidden" name="sy_from" value="<%=WI.getStrValue(strTemp)%>"> 
        <input type="hidden" name="sy_to" value="<%=WI.getStrValue(strErrMsg)%>">
        </td>
    </tr>
    <%if(vEvalPeriod != null && vEvalPeriod.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Evaluation Period</td>
      <td><select name="eval_period_index">
          <%
	  strTemp = WI.fillTextValue("eval_period_index");	
	  for(int i = 0; vEvalPeriod != null && i < vEvalPeriod.size(); i += 3) {
	  	if(strTemp.compareTo((String)vEvalPeriod.elementAt(i)) == 0){%>
          <option value="<%=(String)vEvalPeriod.elementAt(i)%>" selected><%=(String)vEvalPeriod.elementAt(i + 1)%> - <%=(String)vEvalPeriod.elementAt(i + 2)%></option>
          <%}else{%>
          <option value="<%=(String)vEvalPeriod.elementAt(i)%>"><%=(String)vEvalPeriod.elementAt(i + 1)%> - <%=(String)vEvalPeriod.elementAt(i + 2)%></option>
          <%}
	  }%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Evaluator ID</td>
      <td><input value="<%=(String)request.getSession(false).getAttribute("userId")%>" name="eval_id" class="textbox" type="text" id="eval_id" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        Date of Evaluation : 
        <input  value="<%=WI.fillTextValue("date_eval")%>" name="date_eval" class="textbox" type="text"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10"> 
        <a href="javascript:show_calendar('staff_profile.date_eval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <%}//only if vEvalPeriod is not null.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
<%strErrMsg = null;
if (WI.fillTextValue("emp_id").length() > 0 && WI.fillTextValue("criteria_index").length() > 0 
	&& WI.fillTextValue("sy_from").length()== 4 && WI.fillTextValue("sy_to").length() == 4 && WI.fillTextValue("date_eval").length() > 0){
			vRetResult = hrES.operateOnEvaluationPoints(dbOP,request,4);
			if (vRetResult == null){
				strErrMsg = hrES.getErrMsg();
			}
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="5" bgcolor="#FFFFFF">
    <tr> 
      <td><hr size="1"><strong> <%=WI.getStrValue(strErrMsg,"")%></strong> 
	  <% if (vRetResult!= null  && vRetResult.size() > 0){%> 
	  <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <%}%> <table width="400" border="0" align="center">
          <tr> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=1>";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> </td>
          </tr>
        </table>
        <br> <% if (vRetResult != null && vRetResult.size() > 0) {%> <table width="90%" border="0" align="center" cellpadding="0" cellspacing="3">
          <tr> 
            <td colspan="2"><div align="center"><strong>ITEMS</strong></div></td>
            <td width="13%"><div align="center"><strong>(MAX)</strong></div></td>
            <td width="13%"><div align="center"><strong>POINTS</strong></div></td>
          </tr>
   <%  float fMaxPoints = 0f;
   for (int i = 0,j=0; i < vRetResult.size() ; i+=12,++j) {
	fMaxPoints += Float.parseFloat((String)vRetResult.elementAt(i+4));
	if ((String)vRetResult.elementAt(i+10) != null) {
%>          
			<tr bgcolor="#CCCCCC"> 
            <td colspan="4"><strong><font color="#FF0000"><%=(String)vRetResult.elementAt(i+10)%></font></strong> <div align="center"></div></td>
          </tr>
          <%} // end if %>
          <tr> 
            <td width="3%">&nbsp;</td>
            <td width="84%"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
            <td align="center"> <input value="<%=(String)vRetResult.elementAt(i+4)%>" name="max_point<%=j%>" 
			readonly type= "text"  class="textbox_noborder"  size="6" maxlength="4"> 
            </td>
            <td align="center">
		<%
		if(vEditInfo != null && (iIndexEdit = vEditInfo.indexOf(vRetResult.elementAt(i+6),2)) != -1) {
			strTemp = (String)vEditInfo.elementAt(iIndexEdit + 1);
			vEditInfo.removeElementAt(iIndexEdit);vEditInfo.removeElementAt(iIndexEdit);
		}
		else	
			strTemp = WI.fillTextValue("point"+j);
		%>	
			<input value="<%=strTemp%>" name="point<%=j%>" type= "text" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onblur='AllowOnlyInteger("staff_profile","point<%=j%>");style.backgroundColor="white"'
			 onChange="EvalTotal('<%=(String)vRetResult.elementAt(i+4)%>',<%=j%>);"  size="4" maxlength="3" 
			 onKeyUP='AllowOnlyInteger("staff_profile","point<%=j%>")'>
			 
			 <input type="hidden" name="eval_sheet_i_<%=j%>" value="<%=(String)vRetResult.elementAt(i+6)%>">
		    </td>
          </tr>
<%} //end for loop %>
          <tr> 
            <td>&nbsp;</td>
            <td><div align="right"><strong>TOTAL POINTS</strong></div></td>
            <td align="center"> <input value ="<%="("+fMaxPoints+")"%>" name="max_points" type= "text"  
			class="textbox_noborder"  size="7" maxlength="10" readonly> 
            </td>
            <td align="center">
		<%
		if(vEditInfo != null)
			strTemp = (String)vEditInfo.elementAt(1);
		else	
			strTemp = WI.fillTextValue("g_total");
		%>	<input value="<%=strTemp%>" name="g_total" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="3" readonly></td>
          </tr>
		  <tr> 
            <td colspan="4"><strong><font color="#FF0000">COMMENTS</font></strong><br>
          <%
		if(vEditInfo != null)
			strTemp = (String)vEditInfo.elementAt(2);
		else	
			strTemp = WI.fillTextValue("comment");
		%>      <textarea name="comment" cols="70" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
            </td>
          </tr>
 <%
 if(WI.fillTextValue("view_only").length() == 0) {%>
          <tr> 
            <td colspan="4"><div align="center"> <font size="1">
			<%if(iAccessLevel > 1){ 
				if(vEditInfo == null){%>
			<a href="javascript:AddRecord()"><img src="../../../images/save.gif" border="0"></a>
				click to save entries
			<%}else{%>
			<a href="javascript:AddRecord()"><img src="../../../images/edit.gif" border="0"></a>
				click to edit entries
			<%}%> 
			<%if(iAccessLevel == 2 && vEditInfo != null) {%>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				&nbsp;&nbsp;&nbsp;
				<a href="javascript:DeleteRecord();"><img src="../../../images/delete.gif" border="0"></a>click to delete entries
            <%}
			}%>&nbsp;&nbsp;&nbsp;
			<a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>
			Click to clear entries in this page.
			</font> </div></td>
          </tr>
<%}%>
        </table>
        <hr size="1"> <%} // (vRetResult != null && vRetResult.size() > 0) %> 
	  </td>
    </tr>
  </table>
<%} //end all primary entries found %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<%
int iMaxDisp = 0; 
if(vRetResult != null && vRetResult.size() > 0) {
	iMaxDisp = vRetResult.size() / 12;
}%>
<input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
<!-- forced to a name refrence. -->
<input type="hidden" name="eval_name_index" value="1">
<%
if(vEditInfo != null){%>
<input type="hidden" name="info_index" value="<%=(String)vEditInfo.elementAt(0)%>">
<%}%>
<input type="hidden" name="view_only" value="<%=WI.fillTextValue("view_only")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
