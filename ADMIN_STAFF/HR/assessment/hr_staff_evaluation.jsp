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
	
	function UpdateComment(objRemark, strCriteriaMainIndex){
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
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6401&new_value="+escape(objRemark.value)+
		"&criteria_main_index="+strCriteriaMainIndex+
		"&criteria_index="+document.form_.cIndex.value+
		"&eval_personnel_index="+strEvalPersonnelIndex;
		this.processRequest(strURL);
		
	}
	
	function AjaxUpdateScore(strSubCriteriaIndex, objRemark) {
		if(!isInputValid(objRemark))			
			return;
		
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
		
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=6400&new_value="+escape(objRemark.value)+
		"&criteria_sub_index="+strSubCriteriaIndex+
		"&eval_personnel_index="+strEvalPersonnelIndex;
		this.processRequest(strURL);
	}
	
	function isInputValid(objRemark){
		var strRatingScore = document.form_.rating_score.value;
		if(strRatingScore.indexOf(objRemark.value) == -1)
			return false;
					
		return true;
	}
	
	
	function ValidateInput(strTempFieldID, strLabelID, strFieldID, strItemCount, strPostFix){
		var strFieldValue = eval('document.form_.'+strTempFieldID+'.value');
		var strRatingScore = document.form_.rating_score.value;
		if(strRatingScore.indexOf(strFieldValue) == -1)	{		
			alert("Invalid Score.");
			eval("document.form_."+strTempFieldID+".value=''");	
			return;
		}
		UpdateTotal(strLabelID, strFieldID, strItemCount, strPostFix);
	}
	
	function UpdateTotal(strLabelID, strFieldID, strItemCount, strPostFix){
		strItemCount = eval('document.form_.'+(strItemCount+strPostFix) +'.value');
		if(strItemCount.length == 0 || strItemCount == "0")
			return;
		
		strLabelID = strLabelID + strPostFix;
		
		var strTotalValue = "";
		var strFieldValue = "";
		for(var i = 1; i <=strItemCount; ++i ){
			strFieldValue = eval('document.form_.'+(strFieldID+i+"_"+strPostFix)+'.value');
			if(strFieldValue.length > 0){
				if(strTotalValue.length == 0)
					strTotalValue = strFieldValue;
				else
					strTotalValue = parseInt(strTotalValue) + parseInt(strFieldValue);
			}			
		}						
		document.getElementById(strLabelID).innerHTML = strTotalValue;				
		UpdateTotalPerformance();
	}
	
	function UpdateTotalPerformance(){
		var iTotalCount = document.form_.total_comment_count.value;
		var strValue = "";
		var strTotalValue = "";
		for(var i = 1; i <= iTotalCount; ++i ){
			strValue = document.getElementById('raw_score_total_'+i).innerHTML;
			if(strValue.length > 0){
				if(strTotalValue.length == 0)
					strTotalValue = strValue;
				else
					strTotalValue = parseInt(strTotalValue) + parseInt(strValue);
			}
		}		
		document.getElementById('total_performance').innerHTML = strTotalValue;
	}
	
	function LoadTotalPerformance(){
		var iTotalCount = document.form_.total_comment_count.value;
		var strValue = "";
		var strTotalValue = "";
		var iItemCount = "";
		var iFieldValue  = "";
		var strCommentTotal = "";
		for(var i = 1; i <= iTotalCount; ++i ){
			
			iItemCount = eval('document.form_.item_count_'+i+'.value');
			if(iItemCount.length == 0 || iItemCount == "0")
				continue;
				
			strCommentTotal = "";
			for(var k = 1; k <= iItemCount; ++k ){
				iFieldValue = eval('document.form_.raw_score_'+(k+"_"+i)+'.value');
				if(iFieldValue.length > 0){
					if(strCommentTotal.length == 0)
						strCommentTotal = iFieldValue;
					else
						strCommentTotal = parseInt(strCommentTotal) + parseInt(iFieldValue);
				}
			}
			
			document.getElementById('raw_score_total_'+i).innerHTML = strCommentTotal;
			
			strValue = document.getElementById('raw_score_total_'+i).innerHTML;
			if(strValue.length > 0){
				if(strTotalValue.length == 0)
					strTotalValue = strValue;
				else
					strTotalValue = parseInt(strTotalValue) + parseInt(strValue);
			}
		}		
		document.getElementById('total_performance').innerHTML = strTotalValue;

	}
	
</script>
<body <%if(!bolPrintPage){%> bgcolor="#663300" class="bgDynamic" <%}%> onLoad="LoadTotalPerformance();" onUnload="Close();">
<%
	DBOperation dbOP = null;
	
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
								"Admin/staff-HR-Assessment and Evaluation","hr_staff_evaluation.jsp");
								
								
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
			<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br><br>
			STAFF PERFORMANCE EVALUATION
		</td>
	</tr>
</table> 
<br>
<%}

if(vEmpRec != null && vEmpRec.size() > 0){%>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td colspan="3" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td height="40" width="34%" valign="top">Name(Last)<br><strong><%=(String)vEmpRec.elementAt(3)%></strong></td>
					<td width="26%" valign="top">(First)<br><strong><%=(String)vEmpRec.elementAt(1)%></strong></td>
					<%
					strTemp = WI.getStrValue((String)vEmpRec.elementAt(2));
					if(strTemp.length() > 0)
						strTemp = strTemp.substring(0)+".";
					%>
					<td width="40%" valign="top">(M.I.)<br><strong><%=strTemp%></strong></td>
				</tr>
			</table>
		</td>
		<td valign="top" width="21%" class="thinborder">Position:<br>
	    <strong><%=(String)vEmpRec.elementAt(15)%></strong></td>
	</tr>
	<tr>
		<td valign="top" height="40" width="22%" class="thinborder">Performance Period:<br>
	    <strong><%=strEvaluationPeriod%></strong></td>
		<td valign="top" width="20%" class="thinborder">Discussion Date:<br>
		<%
		strTemp = "&nbsp;";
		strErrMsg = "&nbsp;";
		if(vEvaluatorInfo != null && vEvaluatorInfo.size() > 0){
			strTemp = WebInterface.formatName((String)vEvaluatorInfo.elementAt(2), (String)vEvaluatorInfo.elementAt(3),(String)vEvaluatorInfo.elementAt(4),4);	
			strErrMsg = (String)vEvaluatorInfo.elementAt(5);
		}
		%>
	    <strong><%=strErrMsg%></strong></td>		
		<td valign="top" width="37%" class="thinborder">Name and Title of Supervisor:<br>
	    <strong><%=strTemp%></strong></td>
		<%
		if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
		else{
			strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
			if((String)vEmpRec.elementAt(14) != null)
				strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
		}
		%>
		<td valign="top" class="thinborder">Department:<br><strong><%=strTemp3%></strong></td>
	</tr>
</table>
<%


if(vRatingScale != null && vRatingScale.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td class="thinborderBOTTOM" colspan="5" style="padding-left:30px;"><strong>PERFORMANCE FACTOR RATING SCALE</strong></td></tr>
	<tr>
		<%
		for(int i = 0; i < vRatingScale.size(); i+=2){
			if(strRatingScore == null)
				strRatingScore = (String)vRatingScale.elementAt(i+1);
			else
				strRatingScore += "," + (String)vRatingScale.elementAt(i+1);
		%>
		<td class="thinborder" valign="top" width="20%" align="center"><%=vRatingScale.elementAt(i+1)%><br>
			<%=vRatingScale.elementAt(i)%>
		</td>		
		<%}%>
	</tr>
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong>PERFORMANCE FACTORS</strong></td>
		<td width="12%" class="thinborder" style="padding-left:10px;"><strong>Rating</strong></td>
	</tr>
	
<%
int iIndexOf = 0;
int iCommentCount = 0;
int iCount = 0;
int iListCount = 0;

boolean bolShowComment = false;

String strCurrEvalMainIndex = null;
String strPrevEvalMainIndex = "";

String strRomanCount = null;
for (int i = 0; i < vRetResult.size(); i +=6) {

	strCurrEvalMainIndex = (String)vRetResult.elementAt(i+2);
	if(strPrevEvalMainIndex.length() == 0)
 		strPrevEvalMainIndex = strCurrEvalMainIndex;

	if ((String)vRetResult.elementAt(i+3) != null){
		
		strRomanCount = ESExtn.getRomanNumber(++iCount);
		
	if(i > 0){
		strTemp = WI.fillTextValue("comment_"+iCommentCount);
		
		iIndexOf = vEvalComment.indexOf(strEvalPersonnelIndex+"_"+strCriteriaIndex+"_"+strPrevEvalMainIndex);
		if(iIndexOf > -1)
			strTemp = (String)vEvalComment.elementAt(iIndexOf + 2);
			

%>		
	<tr>
		
		<td height="30" colspan="3" valign="top" class="thinborder" style="padding-left:10px;padding-top:3px;"><strong>DOCUMENTATION/COMMENTS</strong><br>
		<%if(!bolPrintPage){%>
			<textarea cols="60" rows="1" 
			 style="text-align:left"			 
			 class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'"
				name="comment_<%=++iCommentCount%>"
				onBlur="UpdateComment(document.form_.comment_<%=iCommentCount%>,'<%=strPrevEvalMainIndex%>');style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
		<%}else{%>
			<input type="hidden" name="comment_<%=++iCommentCount%>" value="<%=WI.getStrValue(strTemp)%>">
			<%=WI.getStrValue(strTemp, "&nbsp;")%><%}%>
		</td>
		<td valign="top" style="padding-left:10px;padding-top:3px;" class="thinborder"><strong>TOTAL <br>
			<label id="raw_score_total_<%=iCommentCount%>" style="position:absolute;" ></label></strong></td>
	</tr>
	<input type="hidden" name="item_count_<%=iCommentCount%>" value="<%=iListCount%>">
<%
if(!strPrevEvalMainIndex.equals(strCurrEvalMainIndex))
	strPrevEvalMainIndex = strCurrEvalMainIndex;
}%>
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong><%=strRomanCount%>. <%=(String)vRetResult.elementAt(i+3)%></strong></td>
		<td style="padding-left:10px;" class="thinborder">&nbsp;</td>
	</tr>	
<%
iListCount = 0;
}%>	
	<tr>
		<td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><%=++iListCount%>. <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
		<%
		strTemp = WI.fillTextValue("raw_score_"+iListCount+"_"+(iCommentCount+1));
		iIndexOf = vRatingScore.indexOf(strEvalPersonnelIndex+"_"+(String)vRetResult.elementAt(i+4));
		if(iIndexOf > -1){
			strTemp = WI.getStrValue((String)vRatingScore.elementAt(iIndexOf+2));
			if(strTemp.length() > 0)
				strTemp = Integer.toString( (int)Double.parseDouble(strTemp));
		}
		%>
		<td style="padding-left:10px;" class="thinborder">
		<%if(!bolPrintPage){%>
			<input name="raw_score_<%=iListCount+"_"+(iCommentCount+1)%>" type="text" class="textbox"   
				onFocus="style.backgroundColor='#D3EBFF'" size="3" maxlength="1" value="<%=strTemp%>"
			    onKeyUp="ValidateInput('raw_score_<%=iListCount+"_"+(iCommentCount+1)%>','raw_score_total_','raw_score_',
					'item_count_','<%=iCommentCount+1%>');"
				onBlur="AjaxUpdateScore('<%=vRetResult.elementAt(i+4)%>', document.form_.raw_score_<%=iListCount+"_"+(iCommentCount+1)%>);style.backgroundColor='white'">
		<%}else{%>
			<input type="hidden" name="raw_score_<%=iListCount+"_"+(iCommentCount+1)%>" value="<%=strTemp%>">
			<%=WI.getStrValue(strTemp, "&nbsp;")%>
		<%}%>
		</td>
	</tr>
<%
//so that last comment will have corrent value
strCurrEvalMainIndex = (String)vRetResult.elementAt(i+2);
}

strTemp = WI.fillTextValue("comment_"+(++iCommentCount));
		
iIndexOf = vEvalComment.indexOf(strEvalPersonnelIndex+"_"+strCriteriaIndex+"_"+strPrevEvalMainIndex);
if(iIndexOf > -1)
	strTemp = (String)vEvalComment.elementAt(iIndexOf + 2);
%>	
	<tr>
		<td height="30" colspan="3" valign="top" class="thinborder" style="padding-left:10px;padding-top:3px;"><strong>DOCUMENTATION/COMMENTS</strong><br>
		<%if(!bolPrintPage){%>
			<textarea cols="60" rows="1" 
			 style="text-align:left"			 
			 class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'"
				name="comment_<%=iCommentCount%>"
				onBlur="UpdateComment(document.form_.comment_<%=iCommentCount%>,'<%=strCurrEvalMainIndex%>');style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
		<%}else{%>
			<input type="hidden" name="comment_<%=iCommentCount%>" value="<%=WI.getStrValue(strTemp)%>">
			<%=WI.getStrValue(strTemp, "&nbsp;")%><%}%>
		</td>
		<td valign="top" style="padding-left:10px;padding-top:3px;" class="thinborder"><strong>TOTAL <br>
			<label id="raw_score_total_<%=iCommentCount%>" style="position:absolute;" ></label></strong></td>
	</tr>
	<input type="hidden" name="item_count_<%=iCommentCount%>" value="<%=iListCount%>">
	
	<input type="hidden" name="total_comment_count" value="<%=iCommentCount%>">
	<tr>
	    <td height="18" colspan="3" class="thinborder" style="padding-left:10px;"><strong>TOTAL PERFORMANCE</strong></td>
	    <td style="padding-left:10px;" class="thinborder">&nbsp;
			<label id="total_performance" style="position:absolute; font-weight:bold; font-size:13px;"></label>
		</td>
    </tr>
<%if(bolPrintPage){%>
	<tr>
		<%
		
		strTemp = "__________________";
		strErrMsg = "________________________";
		if(vEvaluatorInfo != null && vEvaluatorInfo.size() > 0){
			strTemp = WebInterface.formatName((String)vEvaluatorInfo.elementAt(2), (String)vEvaluatorInfo.elementAt(3),(String)vEvaluatorInfo.elementAt(4),4);
			strTemp = "<u>"+strTemp+"</u>";
			strErrMsg = "<u>"+(String)vEvaluatorInfo.elementAt(5)+"</u>";
		}
		
		%>
	    <td width="34%" rowspan="5" valign="top" class="thinborder" style="padding-left:10px;">
		TRAINING/DEVELOPMENT RECOMMENDATIONS:<br>
		<br><br>
		EVALUATOR: <%=strTemp%><br><br><br>
		Date: <%=strErrMsg%>
		</td>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;"><strong>Points</strong></td>
	    <td width="27%" class="thinborder" style="padding-left:10px;"><strong>Percentage</strong></td>
	    <td style="padding-left:10px;" class="thinborder"><strong>Adjectival Rating</strong></td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">77-96</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">91-100%</td>
	    <td style="padding-left:10px;" class="thinborder">Excellent</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">59-76</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">82-90%</td>
	    <td style="padding-left:10px;" class="thinborder">Very Satisfactory</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">45-58</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">75-81%</td>
	    <td style="padding-left:10px;" class="thinborder">Satisfactory</td>
    </tr>
	<tr>
	    <td width="27%" height="22" class="thinborder" style="padding-left:10px;">31-44</td>
	    <td width="27%" class="thinborder" style="padding-left:10px;">68-74%</td>
	    <td style="padding-left:10px;" class="thinborder">Unsatisfactory</td>
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
		<td>: HRD 009-A</td>
	</tr>
	<tr>
		<td>Rev. No.</td>
		<td>: 07</td>
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
