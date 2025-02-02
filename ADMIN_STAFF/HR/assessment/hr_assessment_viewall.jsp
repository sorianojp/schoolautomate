<%@ page language="java" import="utility.*,hr.HREvaluationSheet,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
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
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	//document.form_.searchEmployee.value = "";
	//document.form_.print_page.value = "";
	document.form_.submit();
}
function SearchEmployee()
{
	//document.form_.searchEmployee.value = "1";
	//document.form_.print_page.value = "";
	document.form_.submit();
}
function ViewDetail(strEmpID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?emp_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintPg() {
//	document.form_.print_page.value = 1;
//	document.form_.submit();
}
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.form_.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.form_.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		eval('document.form_.'+strOthFieldName+'.value=\'\'');
		hideLayer(strTextBoxID);
		eval('document.form_.'+strOthFieldName+'.disabled=true');
	}
}
function ViewDetail(strInfoIndex,strEvalDate) {
	var pgLoc = "./hr_assessment.jsp?emp_id="+escape(document.form_.emp_id.value)+"&info_index="+strInfoIndex+
	 "&date_eval="+strEvalDate+"&criteria_index="+document.form_.criteria_index.value+
	 "&sy_from="+document.form_.sy_from.value+"&view_only=1";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.emp_id.value;

		if(strCompleteName.length <=2)
			return;

		var objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.form_.emp_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strRootPath = null;
	String strImgFileExt = null;
	
	Vector vRetResult  = null;
	Vector vYearInfo   = null;
	Vector vEvalPeriod = null;
	Vector vEmpRec     = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment_viewall.jsp");
		
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
														"hr_assessment_viewall.jsp");
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
  HREvaluationSheet hrES = new HREvaluationSheet(request);
  if(WI.fillTextValue("criteria_index").length() > 0) {
	 vYearInfo = hrES.getEvalSheetYearInfo(dbOP, WI.fillTextValue("criteria_index"));
	 if(vYearInfo == null) {
	 	strErrMsg = hrES.getErrMsg();
	}
  }
if(WI.fillTextValue("sy_from").length() > 0) {
	vEvalPeriod = hrES.operateOnEvalPeriod(dbOP, request, 4);
}
if(vEvalPeriod != null && WI.fillTextValue("emp_id").length() > 0) {
	//get Employee information here. 
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() ==0) {
		strErrMsg = authentication.getErrMsg();
	}
	else {
		vRetResult = hrES.operateOnEvalPersonnelDtls(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = hrES.getErrMsg();
	}
}

%>
<form action="./hr_assessment_viewall.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          VIEW EVALUATION DETAIL ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="19%">Evaluation Criteria</td>
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
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Evaluation Period</td>
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
        </select> &nbsp;&nbsp;&nbsp; <input name="image" type="image" onClick="SearchEmployee();" src="../../../images/refresh.gif"></td>
    </tr>
    <%
/////////////////////// show only if vEvalPeriod is not null
if(vEvalPeriod != null && vEvalPeriod.size() > 0) {%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="23%">Employee ID </td>
      <td width="75%"> <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" onKeyUp="AjaxMapName('1');">
	  
	  <label id="coa_info" style="font-size:11px;"></label> 
      </td>
    </tr>
    <tr> 
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%}//only if vEvalPeriod is not null
  if(vEmpRec != null){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="25%" height="25"></td>
      <td width="34%" valign="top" align="left"><font size="1">
	  <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}%> <strong><%=WI.getStrValue(strTemp)%></strong><br> <%=WI.getStrValue(strTemp2)%><br> <%=WI.getStrValue(strTemp3)%>
	<hr size="1" width="100%" color="#0000FF">
	<%if(vRetResult != null && vRetResult.elementAt(1) != null){///show final evaluation.%>
        <strong>::: Final Evaluation :::</strong><br>
		Rating : <%=(String)vRetResult.remove(1)%><br>
		Comments : <%=(String)vRetResult.remove(1)%><br>
		Suggestions : <%=(String)vRetResult.remove(1)%>
	<%}else if(vRetResult != null) {vRetResult.removeElementAt(1);vRetResult.removeElementAt(1);vRetResult.removeElementAt(1);	}%>
	  </font></td>
      <td width="41%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <img src="../../../upload_img/<%=WI.fillTextValue("emp_id").toUpperCase()%>.<%=strImgFileExt%>" width=150 height=150 border=1>
	  </td>
    </tr>
  </table>

<%}if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
    <tr> 
      <td width="50%" height="25">&nbsp;&nbsp;&nbsp;Average Points : <%=(String)vRetResult.remove(0)%></td>
      <td width="50%" align="right"><!--
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif"></a> 
        <font size="1">click to print result</font>--></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="14%" height="25"  class="thinborder"><div align="center"><strong><font size="1">EVALUATOR ID </font></strong></div></td>
      <td width="18%" class="thinborder"><div align="center"><strong><font size="1">EVALUATOR NAME (LNAME,FNAME MI)</font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong><font size="1">EVAL. DATE </font></strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong><font size="1">TOTAL POINTS</font></strong></div></td>
      <td width="34%" class="thinborder"><div align="center"><strong><font size="1">COMMENTS</font></strong></div></td>
      <!--
	  <td width="12%" class="thinborder"><font size="1"><strong>VIEW DETAIL</strong></font></td>
    -->
	</tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i +=6){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <!--
	  <td class="thinborder">&nbsp;<a href='javascript:ViewDetail("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i + 3)%>");'><img src="../../../images/view.gif" border="0"></a></td>
    	-->
	</tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%"><div align="right"></div></td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>