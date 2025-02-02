<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function PrintPage()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	
	document.getElementById('myTable3').deleteRow(0);	
	
	document.getElementById('myTable4').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);	
		
	
	window.print();
}

function UpdateExamName(){
	var pgLoc = "./add_score_rating_exam_name.jsp?exam_main_index="+document.form_.exam_main_index.value;			
	var win=window.open(pgLoc,"UpdateExamName",'width=800,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}



function UpdateLabel(strLevelID,strScoreIndex, strAction) {
	var newVal = prompt('Please enter new Value');
	if(newVal == null)
		return;
	
	document.form_.score_new.value = newVal;	
	document.form_.page_action.value = strAction;	
	document.form_.info_index.value = strScoreIndex; 		
	document.getElementById(strLevelID).innerHTML = newVal;	
	document.form_.submit();
}


</script>


<body bgcolor="#D2AE72">
<form name="form_" action="./score_rating.jsp" method="post">
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","score_rating.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-IQ Score Rating",request.getRemoteAddr(), null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(scoreConversion.operateOnIQRating(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = scoreConversion.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
		strPrepareToEdit = "";
		
	}
}
Vector vAge = new Vector();
Vector vIQRating = new Vector();
Vector vResult = new Vector();

vRetResult = scoreConversion.operateOnIQRating(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = scoreConversion.getErrMsg();
	
if(strPrepareToEdit.length() > 0){
	vEditInfo = scoreConversion.operateOnIQRating(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = scoreConversion.getErrMsg();
}

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          I.Q. SCORE RATING ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">I.Q. Test Name</td>
		<td>
		<select name="rating_main_index" onChange="document.form_.submit();">
		<option value=""></option>
		<%=dbOP.loadCombo("RATING_MAIN_INDEX","IQ_EXAM_NAME", " from CDD_IQ_RATING_EXAM_NAME where is_valid = 1 order  by iq_exam_name", WI.fillTextValue("rating_main_index"), false)%>
		</select>
		<a href="javascript:UpdateExamName();">
		<img src="../../../../images/update.gif" border="0" align="absmiddle"></a>
		</td>
	</tr>
	
	<%if(WI.fillTextValue("rating_main_index").length() > 0){%>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Age</td>
		<td>
		<input type="text" name="age_" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','age_');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','age_')" size="5" maxlength="5" value="<%=WI.fillTextValue("age_")%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Score</td>
		<td>
		<input type="text" name="score_" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','score_');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','score_')" size="5" maxlength="5" value="<%=WI.fillTextValue("score_")%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>IQ Score</td>
		<td>
		<select name="iq_rating">
	<%
	for(int i = 20; i <= 161; i++){
		strTemp = WI.fillTextValue("iq_rating");
		if(strTemp.equals(i+""))
			strTemp = "selected";
		else
			strTemp = "";
		
	%>	
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	<%
			if(i < 142)
 				i++;
			if(i == 143)
				i = 145;
			else if(i == 146)
				i = 149;
			else if(i == 150)
				i = 154;
			else if(i == 155)
				i = 159;
			
			

	}%>
		</select>
		</td>
	</tr>
	
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
		<a href="javascript:PageAction('1','');">
		<img src="../../../../images/save.gif" border="0"></a>		
		<font size="1">Click to save rating</font>
		</td>
	</tr>
	<%}%>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>
  
<%if(vRetResult != null && vRetResult.size() > 0){
vAge = (Vector)vRetResult.remove(0);
vIQRating = (Vector)vRetResult.remove(0);
vResult = (Vector)vRetResult.remove(0);

%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable3">
	<tr><td colspan="3" align="right">
		<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a></td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>



<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">

	<tr>
		<td class="thinborder" align="center" height="25" width="10%">Age</td>
	<%
	
	for(int i = 0; i < vAge.size(); i++){		
		strTemp = (String)vAge.elementAt(i);
		if(i + 1 == vAge.size())
			strTemp = strTemp+"+ Adult";		
	%>
		<td class="thinborder" align="center" width="10%"><%=strTemp%></td>
	<%}%>		
		<td class="thinborder" align="center">I.Q.</td>
	</tr>

	<%
	int iIndexOf = 0;
	String strScore = "";
	String strIQRating = "";	
	String strScoreIndex = "";
	
	boolean bolIsLast = false;
	for(int i = 0;i < vIQRating.size(); i++){
		strTemp = (String)vIQRating.elementAt(i);		
		strIQRating = strTemp;		
		
		int iTemp = Integer.parseInt(WI.getStrValue(strIQRating,"0"));		
		if(iTemp == 161)
			strIQRating = "160";
		else
			strIQRating = strTemp;	
		if( i + 1 == vIQRating.size()){
			strIQRating = strIQRating+"+";			
			bolIsLast = true;
		}else
			bolIsLast = false;
		
		
	%>

	<tr>
		<td class="thinborder" height="25">&nbsp;</td>
		<%		
		
		for(int x = 0; x < vAge.size(); x++){
			for(int y = 0; y < vResult.size(); y+=6){
				iIndexOf = vResult.indexOf((String)vAge.elementAt(x)+"-"+strTemp);
				if(iIndexOf == -1){
					strScore = "&nbsp;";
					continue;
				}
				strScoreIndex = (String)vResult.elementAt(iIndexOf - 1);
				strScore = (String)vResult.elementAt(iIndexOf + 2);
				
				if( i + 1 == vIQRating.size())
					strScore = strScore+"+";
			}
		
		%>
		<td class="thinborder" align="center"><label id="label_score_new" onClick="UpdateLabel('label_score_new','<%=strScoreIndex%>','6')"><%=strScore%></label></td>
		<%}%>
	
		<td class="thinborder" align="center"><%=strIQRating%></td>
	</tr>

	<%}%>


</table>

<%}//end of vRetResult not null%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="exam_main_index" value="<%=WI.fillTextValue("exam_main_index")%>" />


<input type="hidden" name="score_new" value="<%=WI.fillTextValue("score_new")%>" />


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
