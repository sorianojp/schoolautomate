<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheetExtn" %>
<%
String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
String strEmpID = (String)request.getSession(false).getAttribute("userId");
if(strEmpID == null)
	strEmpID = "";
if(strAuthID == null){%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are already logged out. Please login again.</font></p>
<%return;}
if(strAuthTypeIndex != null && strAuthTypeIndex.equals("4")) {%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are no longer authorized to view this page. Please login again.</font></p>
<%return;}


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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">
	function ReloadPage(){
		document.staff_profile.submit();
	}
	
	function EvaluateStaff(strUserIndex, strIDNumber, strIsPrint, strEvalPersonnelIndex){
		if(strUserIndex.length == 0){
			alert("Please select staff personnel.");
			return;
		}
		
		var strEvaluationType     = document.staff_profile.evaluation_type.value;
		if(strEvaluationType.length == 0){
			alert("Please select evaluation format.");
			return;
		}
		
		var strCriteriaIndex 	  = document.staff_profile.cIndex.value;
		var strSYFrom             = document.staff_profile.sy_from.value;
		var strSYTo 			  = document.staff_profile.sy_to.value;
		var strPeriodFrom 		  = document.staff_profile.period_fr.value;
		var strPeriodTo 		  =	document.staff_profile.period_to.value;		
		var strEvalPeriodIndex 	  = document.staff_profile.eval_period_index.value;
		var strEvalSheetMainIndex = document.staff_profile.eval_sheet_main_index.value;
		
		
		var loadPg = "hr_staff_evaluation.jsp";
		if(strEvaluationType == '2')
			loadPg = "hr_staff_peer_evaluation.jsp";
		
		
		loadPg = loadPg+"?cIndex="+strCriteriaIndex+
		"&user_index="+strUserIndex+
		"&emp_id="+strIDNumber+
		"&sy_from="+strSYFrom+
		"&sy_to="+strSYTo+
		"&period_fr="+strPeriodFrom+
		"&period_to="+strPeriodTo+
		"&eval_period_index="+strEvalPeriodIndex+
		"&evaluation_type="+strEvaluationType+
		"&eval_sheet_main_index="+strEvalSheetMainIndex+	
		"&print_page="+strIsPrint;
		var win=window.open(loadPg,"myfile",'dependent=yes,width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	
	}
	
	function ViewFormat(){
		var strEvaluationType     = document.staff_profile.evaluation_type.value;
		if(strEvaluationType.length == 0){
			alert("Please select evaluation format.");
			return;
		}
		var loadPg = "hr_staff_evaluation_print_sample.jsp";
		if(strEvaluationType == '2')
			loadPg = "hr_staff_peer_evaluation_print.jsp";

		
		var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment.jsp");

		
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

HREvaluationSheetExtn ESExtn = new HREvaluationSheetExtn();
Vector vRetResult = null;
Vector vEvalPeriod = null;
Vector vEvaluatedPersonnel = new Vector();
int iElemCount  = 0;

String strEvalPersonnelIndex = null;
int iIndexOf = 0;
if(WI.fillTextValue("cIndex").length() > 0){
	vEvalPeriod = ESExtn.getActiveEvaluationPeriod(dbOP,WI.fillTextValue("cIndex"));
	if(vEvalPeriod == null)
		strErrMsg = ESExtn.getErrMsg();
	else{
	
		/*
		admin can evaluate every offices, like guidance, edp, accounting(head/members) STAFF-EVALUATION ONLY
		department head ca evaluate their staff/members - STAFF-EVALUATION/PEER EVALUATION
		
		
		they have to set immediate supervisor from HR Management - Personnel - Service Record
		
	
		*/
		vRetResult = ESExtn.getListForEvaluation(dbOP, strAuthID);
		if(vRetResult == null)
			strErrMsg = ESExtn.getErrMsg();
		else
			iElemCount = ESExtn.getElemCount();
			
		vEvaluatedPersonnel = ESExtn.getListOfEvaluatedPersonnel(dbOP, request, strAuthID);
		if(vEvaluatedPersonnel == null)
			vEvaluatedPersonnel = new Vector();
	}

}



%>
<form action="hr_assessment_vma.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EVALUATION RECORD PAGE ::::</strong></font></div></td>
    </tr>    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%" height="25" colspan="2">&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
		<td width="3%" height="25">&nbsp;</td>
        <td width="16%" height="25">Evaluation Criteria</td>
        <td width="81%"> 
			<select name="cIndex" id="cIndex" onChange='ReloadPage();'>
				<option value="0">Select Evaluation Criteria</option>
				<%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> 
			</select>		</td>
   </tr>
   
   
<%
if(vEvalPeriod != null && vEvalPeriod.size() > 0){
%>
	 <tr>
        <td height="25">&nbsp;</td>
        <td height="25">Evaluation Format</td>
        <td>
			<select name="evaluation_type" onChange='ReloadPage();'>
				
				<option value="">Select Evaluation Format</option>
				<%
				strTemp = WI.fillTextValue("evaluation_type");
				if(strTemp.equals("1"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%>
				<option value="1" <%=strErrMsg%>>Format 1</option>
				<%
				
				if(strTemp.equals("2"))
					strErrMsg = "selected";
				else
					strErrMsg = "";
				%>
				<option value="2" <%=strErrMsg%>>Format 2</option>
			</select>
			
			<a href="javascript:ViewFormat();"><img src="../../../images/view.gif" border="0"></a>		</td>
    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td><a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Evaluation Period</td>
		<%
		strTemp = (String)vEvalPeriod.elementAt(0) + " to " + (String)vEvalPeriod.elementAt(1) +"<br><br>"+ 
			(String)vEvalPeriod.elementAt(2) +" - "+ (String)vEvalPeriod.elementAt(3);
		%>
		<td><%=strTemp%></td>
		<input type="hidden" name="sy_from" value="<%=(String)vEvalPeriod.elementAt(0)%>">
		<input type="hidden" name="sy_to" value="<%=(String)vEvalPeriod.elementAt(1)%>">
		<input type="hidden" name="period_fr" value="<%=(String)vEvalPeriod.elementAt(2)%>">
		<input type="hidden" name="period_to" value="<%=(String)vEvalPeriod.elementAt(3)%>">
		
		<input type="hidden" name="eval_period_index" value="<%=(String)vEvalPeriod.elementAt(4)%>">
		<input type="hidden" name="eval_sheet_main_index" value="<%=(String)vEvalPeriod.elementAt(5)%>">
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
<%}%>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){
String strCurrDeptName = null;
String strPrevDeptName = "";
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="20%" height="25" class="thinborder"><strong>ID Number</strong></td>
		<td width="61%" class="thinborder"><strong>Name of Staff</strong></td>
		<td width="19%" class="thinborder" align="center"><strong>Evaluate</strong></td>
	</tr>
<%

for(int i = 0 ; i < vRetResult.size(); i += iElemCount){

	if(strEmpID.equals(vRetResult.elementAt(i+1)))
		continue;

	strCurrDeptName = (String)vRetResult.elementAt(i+6);
if(!strPrevDeptName.equals(strCurrDeptName)){
	strPrevDeptName = strCurrDeptName;
%>	
	<tr>
		<td colspan="3" bgcolor="#999999" height="25" class="thinborder"><%=strCurrDeptName%></td>
	</tr>
<%}%>	
	<tr>
		<td width="20%" height="25" class="thinborder" style="padding-left:30px;"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName( (String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4  );
		%>
		<td width="61%" class="thinborder"><%=strTemp%></td>
		<%
		iIndexOf = vEvaluatedPersonnel.indexOf((String)vRetResult.elementAt(i+1)+"_id_number");
		if(iIndexOf > -1){
			strEvalPersonnelIndex = (String)vEvaluatedPersonnel.elementAt(iIndexOf + 6);			
		}else
			strEvalPersonnelIndex = "";
			
		%>
		<td width="19%" class="thinborder" align="center">
			<a href="javascript:EvaluateStaff('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i+1)%>',
				'0','<%=strEvalPersonnelIndex%>');"><img src="../../../images/forum_new.gif" border="0"></a>
			<%
			if(iIndexOf > -1){
			%>		
			&nbsp; &nbsp;
			<a href="javascript:EvaluateStaff('<%=vRetResult.elementAt(i)%>','<%=vRetResult.elementAt(i+1)%>',
				'1','<%=strEvalPersonnelIndex%>');"><img src="../../../images/print.gif" border="0"></a>
			<%}%>
		</td>
	</tr>
<%}%>
	
</table>
<%}%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td height="25"  colspan="3">&nbsp;</td></tr>
	<tr><td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
