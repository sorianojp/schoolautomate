
<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<%
String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthID == null){%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are already logged out. Please login again.</font></p>
<%return;}
if(strAuthTypeIndex != null && strAuthTypeIndex.equals("4")) {%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are no longer authorized to view this page. Please login again.</font></p>
<%return;}
String[] strColorScheme = CommonUtil.getColorScheme(5);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.

boolean bolPrintPage         = WI.fillTextValue("print_page").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>

.circle{
	border-radius:8px;
	width:16px;
	height:16px;
	border:solid 1px #000000;
	vertical-align:middle;
	text-align:center;
}

.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
	function Close(){
		if(document.form_.is_forwarded.value.length == 0)
			window.opener.ReloadPage();
		window.close();
	}

	function ReloadPage()
	{
		document.form_.submit();
	}
	
	
	
	function AjaxUpdateScore(strSubCriteriaIndex, objRemark, strValue) {	
		
		if(strSubCriteriaIndex.length == 0){
			alert("Sub-Criteria reference is missing.");
			return;
		}
		
		var strEvalPersonnelIndex = document.form_.eval_personnel_index.value;
		if(strEvalPersonnelIndex.length == 0){
			alert("Some information field is lacking.");
			return;
		}
				
		var objCOAInput 		= objRemark;
		
		this.InitXmlHttpObject(objCOAInput, 2);
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6400&new_value="+escape(strValue)+
		"&criteria_sub_index="+strSubCriteriaIndex+
		"&eval_personnel_index="+strEvalPersonnelIndex;
		this.processRequest(strURL);
	}
	

	
</script>
<body <%if(!bolPrintPage){%> bgcolor="#663300" class="bgDynamic" <%}%> onUnload="Close();">
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_staff_evaluation.jsp");
		
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




Vector vRetResult = null;
Vector vEmpRec = null;
Vector vRatingScale = null;
Vector vRatingScore = new Vector();
Vector vEvaluatorInfo = new Vector();
Vector vEvalComment = new Vector();

int iElemCount = 0;

hr.HREvalMain hrS = new hr.HREvalMain();
HREvaluationSheet hrES = new HREvaluationSheet();
hr.HREvaluationSheetExtn ESExtn = new hr.HREvaluationSheetExtn();
enrollment.Authentication authentication = new enrollment.Authentication();
enrollment.FacultyEvaluation facEval = new 	enrollment.FacultyEvaluation();



String strCriteriaIndex 	 = WI.fillTextValue("cIndex");
String strSYFrom 			 = WI.fillTextValue("sy_from");
String strSYTo 				 = WI.fillTextValue("sy_to");
String strUserIndex          = WI.fillTextValue("user_index");
String strIDNumber  		 = WI.fillTextValue("emp_id");

String strPeriodFrom 		 = WI.fillTextValue("period_fr");
String strPeriodTo 		     = WI.fillTextValue("period_to");

String strEvalPeriodIndex 	 = WI.fillTextValue("eval_period_index");
String strEvalSheetMainIndex = WI.fillTextValue("eval_sheet_main_index");

if(strEvalPeriodIndex.length() > 0 && (strPeriodFrom.length() == 0 || strPeriodTo.length() == 0 || strEvalSheetMainIndex.length() == 0)){
	strTemp = "select PERIOD_FROM, PERIOD_TO,EVAL_SHEET_MAIN_INDEX from HR_EVAL_EVALPERIOD where EVAL_PERIOD_INDEX = "+strEvalPeriodIndex;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	if(rs.next()){
		strPeriodFrom = ConversionTable.convertMMDDYYYY(rs.getDate(1));
		strPeriodTo = ConversionTable.convertMMDDYYYY(rs.getDate(2));
		strEvalSheetMainIndex = rs.getString(3);
	}rs.close();
}



String strEvaluationPeriod = strPeriodFrom + " - " +strPeriodTo;
String strDateEvaluated = WI.getTodaysDate(6);
String strEvalPersonnelIndex = WI.fillTextValue("eval_personnel_index");




if(strCriteriaIndex.length() == 0 && strUserIndex.length() == 0)
	strErrMsg = "Evaluation criteria or personnel information is missing.";
else{
	

	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() ==0) 
		strErrMsg = authentication.getErrMsg();
	else{
	
		if(strEvalPersonnelIndex.length() == 0)
			strEvalPersonnelIndex = ESExtn.getEvalPersonnalInfo(dbOP, request);
	
		vRatingScale = facEval.operateOnPointSystem(dbOP, request, 4);
		if(vRatingScale == null)
			strErrMsg = facEval.getErrMsg();
		else{
			vRetResult = hrS.operateOnEvaluation(dbOP,request,4);
			if(vRetResult == null)
				strErrMsg = hrES.getErrMsg();	
				
			vRatingScore = ESExtn.getEvaluationPoints(dbOP, strEvalPersonnelIndex);		
			if(vRatingScore == null){
				//strErrMsg = ESExtn.getErrMsg();
				vRatingScore = new Vector();
			}else
				iElemCount = ESExtn.getElemCount();	
				
			vEvaluatorInfo = ESExtn.getEvaluatorInfo(dbOP, strEvalPersonnelIndex);		
			if(vEvaluatorInfo == null){
				if(bolPrintPage && strErrMsg == null)
					strErrMsg = ESExtn.getErrMsg();
				vEvaluatorInfo = new Vector();
			}
			
			vEvalComment = ESExtn.getEvaluationComment(dbOP, request, strEvalPersonnelIndex);
			if(vEvalComment == null)
				vEvalComment = new Vector();
		}
	}	
}



String strRatingScore = null;



%>
<form action="./hr_staff_evaluation.jsp" method="post" name="form_">

<%if(!bolPrintPage){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          ASSESSMENT AND EVALUATION MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
	<tr>
		<td width="76%" height="25"><%=WI.getStrValue(strErrMsg)%>&nbsp;</td>
	    <td width="24%" align="right"><a href="javascript:Close();"><img src="../../../images/close_window.gif" border="0"></a></td>
	</tr>
</table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center">			
			PEER EVALUATION FOR NON-TEACHING PERSONNEL
		</td>
	</tr>
</table> 
<br>
<%}


if(vEmpRec != null && vEmpRec.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="35" valign="bottom" width="15%">NAME OF PEER:</td>
		<%
		strTemp = WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4);
		%>
		<td valign="bottom" width="40%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong><%=strTemp%></strong></div></td>
		<td valign="bottom" width="13%">Position:</td>
		<td valign="bottom" width="32%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong><%=(String)vEmpRec.elementAt(15)%></strong></div></td>
	</tr>
	<tr>
		<td height="35" valign="bottom" width="15%">Period Covered:</td>
		<td valign="bottom" width="40%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong><%=strEvaluationPeriod%></strong></div></td>
		<td valign="bottom" width="13%">Date Evaluated:</td>
		<%
		
		strErrMsg = "&nbsp;";
		if(vEvaluatorInfo != null && vEvaluatorInfo.size() > 0){			
			strErrMsg = (String)vEvaluatorInfo.elementAt(5);
		}
		%>
		<td valign="bottom" width="32%"><div style="border-bottom:solid 1px #000000; width:90%;"><strong><%=strErrMsg%></strong></div></td>
	</tr>
</table>
<%
if(vRatingScale != null && vRatingScale.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="15%">DIRECTION:</td>
		<td colspan="4">Please encircle the number corresponding to your perception of an observable 
			behavior of your peer. The descriptive ratings are as follows:</td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td width="7%">&nbsp;</td>
        <td width="24%">&nbsp;</td>
        <td width="6%">&nbsp;</td>
        <td width="48%">&nbsp;</td>
	</tr>
<%
Vector vTemp = new Vector();

vTemp.addAll(vRatingScale);



while(vTemp.size() > 0){
%>	
	<tr>
	    <td>&nbsp;</td>
		<%
		strTemp = "&nbsp;";
		strErrMsg = "&nbsp;";
		if(vTemp.size() > 0){
			strTemp = (String)vTemp.remove(0);
			strErrMsg = (String)vTemp.remove(0);
		}
		%>
	    <td><%=strErrMsg%></td>
        <td><%=strTemp%></td>
		<%
		strTemp = "&nbsp;";
		strErrMsg = "&nbsp;";
		if(vTemp.size() > 0){
			strTemp = (String)vTemp.remove(0);
			strErrMsg = (String)vTemp.remove(0);
		}
		%>
       	<td><%=strErrMsg%></td>
        <td><%=strTemp%></td>
	</tr>
<%}
%>	
	<tr>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
		 <td>&nbsp;</td>
        <td>NA</td>
        <td>Not Applicable</td>        
	</tr>
	
	<tr>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>(Should the item be unobservable)</td>
	</tr>
</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

<%
int iIndexOf = 0;
int iCommentCount = 0;

int iListCount = 0;


String strClassName = "";

String[] astrConvertLetter = {"","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};

for (int i = 0; i < vRetResult.size(); i +=6) {
	if ((String)vRetResult.elementAt(i+3) != null){
	iListCount = 0;
%>

	<tr><td colspan="2"><strong><%=astrConvertLetter[++iCommentCount]%>. <%=(String)vRetResult.elementAt(i+3)%></strong></td>
	    <%for(int k = 0; k < vRatingScale.size(); k+=2){
			if(bolPrintPage)
				strTemp = "";
			else
				strTemp = (String)vRatingScale.elementAt(k+1);
		%>
		<td align="center"><strong><%=strTemp%></strong></td>
		<%}
		if(bolPrintPage)
			strTemp = "";
		else
			strTemp = "NA";
		%>
		<td align="center"><strong><%=strTemp%></strong></td>
	</tr>
<%}%>
	<tr>
		<td height="17" width="4%" align="right"><%=++iListCount%>.&nbsp;</td>
		<td><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
		
		
		
		
		<%
		
		strTemp = WI.fillTextValue("raw_score_"+iListCount+"_"+(iCommentCount));
		iIndexOf = vRatingScore.indexOf(strEvalPersonnelIndex+"_"+(String)vRetResult.elementAt(i+4));
		if(iIndexOf > -1){
			strTemp = WI.getStrValue((String)vRatingScore.elementAt(iIndexOf+2));
			if(strTemp.length() > 0)
				strTemp = Integer.toString( (int)Double.parseDouble(strTemp));
		}
		
		
		for(int k = 0; k < vRatingScale.size(); k+=2){
			if(strTemp.equals( (String)vRatingScale.elementAt(k+1) )){
				strErrMsg = "checked";
				strClassName = "circle";
			}else{
				strClassName = "";
				strErrMsg = "";
			}
		%>
		<td width="3%" align="center">
			<%if(!bolPrintPage){%>
			<input type="radio" name="raw_score_<%=iListCount+"_"+(iCommentCount)%>" <%=strErrMsg%>
			 onClick="AjaxUpdateScore('<%=vRetResult.elementAt(i+4)%>', document.form_.raw_score_<%=iListCount+"_"+(iCommentCount)%>,'<%=vRatingScale.elementAt(k+1)%>')" >
			 <%}else{%> <div class="<%=strClassName%>"><%=(String)vRatingScale.elementAt(k+1)%></div> <%}%>
		</td>
		<%}
		
		if(strTemp.length() == 0 && iIndexOf > -1){
			strErrMsg = "checked";
			strClassName = "circle";
		}else{
			strErrMsg = "";
			strClassName = "";
		}
		
		%>
		<td width="3%" align="center">
		<%
		if(!bolPrintPage){
		%>
		<input type="radio" name="raw_score_<%=iListCount+"_"+(iCommentCount)%>" <%=strErrMsg%>
			onClick="AjaxUpdateScore('<%=vRetResult.elementAt(i+4)%>', document.form_.raw_score_<%=iListCount+"_"+(iCommentCount)%>,'')" >
		<%}else{%><div class="<%=strClassName%>">NA</div><%}%>
		</td>		
	</tr>	
<%}%>
</table>

<%}
}
if(!bolPrintPage){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>

<%}

else{
%>
<script>window.print();</script>
<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>Form ID</td>
		<td>: HRD 0011</td>
	</tr>
	<tr>
		<td>Rev. No.</td>
		<td>: 05</td>
	</tr>
	<tr>
		<td>Rev. Date</td>
		<td>: 11/19/07</td>
	</tr>
</table>
</div>
<%}%>
<input type="hidden" name="cIndex" value="<%=strCriteriaIndex%>">
<input type="hidden" name="criteria_index" value="<%=strCriteriaIndex%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">


	
<input type="hidden" name="emp_id" value="<%=strIDNumber%>">
<input type="hidden" name="user_index" value="<%=strUserIndex%>">
<input type="hidden" name="period_fr" value="<%=strPeriodFrom%>">
<input type="hidden" name="period_to" value="<%=strPeriodTo%>">
<input type="hidden" name="eval_period_index" value="<%=strEvalPeriodIndex%>">
<input type="hidden" name="eval_sheet_main_index" value="<%=strEvalSheetMainIndex%>">
<input type="hidden" name="evaluation_type" value="<%=WI.fillTextValue("evaluation_type")%>">

<input type="hidden" name="rating_score" value="<%=strRatingScore%>">

<input type="hidden" name="eval_personnel_index" value="<%=strEvalPersonnelIndex%>" >
<input type="hidden" name="is_forwarded" value="<%=WI.fillTextValue("is_forwarded")%>">
</form>


</body>
</html>
<%
	dbOP.cleanUP();
%>
