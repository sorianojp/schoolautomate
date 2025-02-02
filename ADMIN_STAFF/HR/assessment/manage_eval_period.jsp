<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet"%>
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
<script language="JavaScript">
function PrepareToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value ="1";
	
	document.form_.page_action.value = "";
	document.form_.info_index.value = strInfoIndex;
	
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	
	this.SubmitOnce('form_');
}
function CancelRecord(){
	document.form_.prepareToEdit.value ="";
	document.form_.page_action.value = "";
	
	document.form_.period_from.value = "";
	document.form_.period_to.value = "";
	
	this.SubmitOnce('form_');
}
function CriteriaChanged() {
	document.form_.c_changed.value = 1;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.c_changed.value = "";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Evaluation Period",
								"manage_eval_period.jsp");

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
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"manage_eval_period.jsp");
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
HREvaluationSheet hrEvalSheet = new HREvaluationSheet();
Vector vRetResult = null;
Vector vEditInfo = null;
Vector vYearInfo = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(hrEvalSheet.operateOnEvalPeriod(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hrEvalSheet.getErrMsg();
	else {	
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "0";
	}
}
if(WI.fillTextValue("c_changed").length() == 0 && WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = hrEvalSheet.operateOnEvalPeriod(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) {
		strErrMsg = hrEvalSheet.getErrMsg();
	}
}
if(WI.fillTextValue("criteria_index").length() > 0) {
	vYearInfo = hrEvalSheet.getEvalSheetYearInfo(dbOP, WI.fillTextValue("criteria_index"));
	if(vYearInfo == null) {
		strErrMsg = hrEvalSheet.getErrMsg();
	}
}
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrEvalSheet.operateOnEvalPeriod(dbOP, request, 3);
}

boolean bolForwarded = WI.fillTextValue("is_forwared").length() > 0;

%>

<form action="./manage_eval_period.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::EVALUATION 
          PERIOD MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="5" ><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table  width="100%" border="0" cellspacing="0" cellpadding="5" bgcolor="#FFFFFF">
    <tr>
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
        <table width="95%" border="0" align="center" cellpadding="0" cellspacing="2">
          <tr> 
            <td width="20%" height="25"><div align="center"><strong>CRITERIA</strong></div></td>
            <td>
			<%
			if(!bolForwarded){
			%>
				<select name="criteria_index" onChange="CriteriaChanged();">
                <option value="">Select a criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("criteria_index"),false)%> </select> 
			<%}else{
				strTemp = "";
				if(WI.fillTextValue("criteria_index").length() > 0){
					strTemp = "select CRITERIA_NAME from HR_EVAL_CRITERIA where CRITERIA_INDEX = "+WI.fillTextValue("criteria_index");
					strTemp  =dbOP.getResultOfAQuery(strTemp, 0);
				}
			%>	<%=strTemp%>
				
				<input type="hidden" name="criteria_index" value="<%=WI.fillTextValue("criteria_index")%>">
			<%}%>			</td>
          </tr>
          <%if(vYearInfo != null && vYearInfo.size() > 0) {%>
          <tr> 
            <td height="25"><div align="center"><strong>Effectivity 
            Year: </strong></div></td>
            <td width="80%"> 
			<%
			String[] astrConvertActiveStat = {""," (Active)"};
			if(!bolForwarded){%>
			<select name="sy_from">
                <%strTemp = WI.fillTextValue("sy_from");
			for(int i =0; i < vYearInfo.size(); i += 3) {
				if(strTemp.compareTo((String)vYearInfo.elementAt(i)) == 0){%>
                <option selected value="<%=(String)vYearInfo.elementAt(i)%>">
				<%=(String)vYearInfo.elementAt(i) +" - "+(String)vYearInfo.elementAt(i + 1) + astrConvertActiveStat[Integer.parseInt((String)vYearInfo.elementAt(i + 2))]%></option>
                <%}else{%>
                <option value="<%=(String)vYearInfo.elementAt(i)%>"><%=(String)vYearInfo.elementAt(i) +" - "+(String)vYearInfo.elementAt(i + 1) + astrConvertActiveStat[Integer.parseInt((String)vYearInfo.elementAt(i + 2))]%></option>
                <%}
			}%>
              </select>&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
			  <%}else{%>
			  	<%=WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")+
					astrConvertActiveStat[Integer.parseInt(WI.getStrValue(WI.fillTextValue("is_active"),"0"))]%>
			  	<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
			  <%}%></td>
          </tr>
          <%}%>
          <tr > 
            <td height="15" colspan="2"><hr size="1"></td>
          </tr>
        </table>
<%
if(vYearInfo != null && vYearInfo.size() > 0 && WI.fillTextValue("c_changed").length() == 0){%>
        <table width="95%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr > 
            <td width="2%" height="25"><div align="center"></div></td>
            <td width="14%">Period From</td>
            <td width="84%" height="25">
<%if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
  else	
  	strTemp = WI.fillTextValue("period_from");
%>
				<input value="<%=strTemp%>" name="period_from" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" readonly="true"> 
              <a href="javascript:show_calendar('form_.period_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
          <tr > 
            <td height="25"><div align="center"></div></td>
            <td height="25">Period To</td>
            <td height="25">
<%if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
  else	
  	strTemp = WI.fillTextValue("period_to");
%>			<input value="<%=strTemp%>" name="period_to" type="text" class="textbox" id="period_to"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" readonly="true"> 
              <a href="javascript:show_calendar('form_.period_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
          <tr > 
            <td height="25"><div align="center"></div></td>
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
          </tr>
          <tr > 
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25"> <%  if (iAccessLevel > 1){
		if (strPrepareToEdit.compareTo("1") !=0){%> <a href="javascript:PageAction('1','');"><img src="../../../images/add.gif" width="42" height="32" border="0"></a><font size="1"> 
              click to add new item 
              <%}else{ %>
              <a href="javascript:PageAction('2','<%=WI.fillTextValue("info_index")%>');"><img src="../../../images/edit.gif" border="0"></a> 
              click to edit item<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>click 
              to cancel edit </font> <%}}%> </td>
          </tr>
        </table>
<%}//if vYearInfo is not null 
	if (vRetResult != null && vRetResult.size() > 0) {%>
        <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="2" bgcolor="#DFD0B9" class="thinborder"><div align="center"><strong>EVALUATION 
                PERIOD LIST</strong></div></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder"><div align="center"><strong><font size="1">PERIOD 
                FROM </font></strong></div></td>
            <td width="28%" class="thinborder"><div align="center"><font size="1"><strong>OPERATIONS</strong></font></div></td>
          </tr>
          <% for (int i =0; i < vRetResult.size() ; i+=3) { %>
          <tr> 
            <td width="72%" height="33" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%> - <%=(String)vRetResult.elementAt(i+2)%></td>
            <td align="center" class="thinborder"> <% if (iAccessLevel >1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a> 
              <%}else{%> &nbsp; <%} if (iAccessLevel == 2) {%> <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a> 
            <%}%></td>
          </tr>
          <%} //end for loop %>
        </table>
<%} // end vRetResult  != null%>

</tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="c_changed" value="<%=WI.fillTextValue("c_changed")%>">

<input type="hidden" name="is_forwared" value="<%=WI.fillTextValue("is_forwared")%>">
<input type="hidden" name="is_active" value="<%=WI.fillTextValue("is_active")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
