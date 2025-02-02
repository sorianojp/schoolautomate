<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.reloadPage.value ="1";
	document.form_.submit();
}
var rowID;
function RemoveQPoints(strInfoIndex, strLabelID,objCOAInput) {
	if(!confirm('Are you sure you want to remove this information?'))
		return;
	//call ajax to delete information.
//	    var objCOAInput;
//		eval('objCOAInput = document.form_.'+strInfoIndex+'_;');

		this.InitXmlHttpObject(objCOAInput, 1);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=103&info_index="+strInfoIndex+"&edit_info=10";

		xmlHttp.onreadystatechange=stateChangedInternal;
		xmlHttp.open("GET",strURL,true);
		xmlHttp.send(null);


}
function stateChangedInternal() {
	if (xmlHttp.readyState==4) {
          if (!xmlHttp.status == 200) {//bad request.
            alert("Connection to server is lost");
            return;
          }
		//alert(xmlHttp.responseText); -- uncomment this to view error/exception...
		this.retObj = xmlHttp.responseText;
		if(this.retObj == "") {
			dynamicObj.value = "Error in processing.";
			return;
		}
		dynamicObj.value     = this.retObj;
		document.getElementById('myADTable1').deleteRow(rowID);
	}
	else
	 	dynamicObj.value     = "Processing..";
}
function findRowNumber(element) { // element is a descendent of a tr element
	while(element.tagName.toLowerCase() != "tr") {
		element = element.parentNode; // breaks if no "tr" in path to root
	}
	//alert(element.rowIndex);
	rowID = element.rowIndex;
	return;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLECommonUtil,OLExam.OLEQuestionnair,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolFatalErr = false;
	String strSubName = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.

OLECommonUtil comUtil = new OLECommonUtil();
OLEQuestionnair qN = new OLEQuestionnair();
strTemp = WI.fillTextValue("edit_info");
if(strTemp.length() > 0)
{
	if(!qN.editQN(dbOP,request))
		strErrMsg = qN.getErrMsg();
	else
		strErrMsg = "Questionnaire edited successfully.";
}

Vector vTeacherList = new Vector();
Vector vSubList = new Vector();
Vector vEditInfo = null; Vector vTemp = null;

///Question order and Question distribution information:
Vector vQNOrder = new Vector();
Vector vQuestionDistribution = new Vector();

String strFacIndex = null;
String strSubIndex = null;

if(WI.fillTextValue("reloadPage").compareTo("1") != 0)
{
	vEditInfo = qN.getEditQNDetail(dbOP, request.getParameter("info_index"));
	if(vEditInfo == null) {
		strErrMsg = qN.getErrMsg();
		bolFatalErr = true;
	}
	else {
		request.setAttribute("teacher",vEditInfo.elementAt(0));
		request.setAttribute("college",vEditInfo.elementAt(5));
		vQuestionDistribution = (Vector)vEditInfo.remove(0);
		vQNOrder = (Vector)vEditInfo.remove(0);
	}
}
vTeacherList = comUtil.getTeacherList(dbOP,request);
if(vTeacherList == null)
{
	if(strErrMsg != null)
		strErrMsg += comUtil.getErrMsg();
	else
		strErrMsg = comUtil.getErrMsg();
	bolFatalErr = true;
}
else
{
	strFacIndex = WI.fillTextValue("teacher");
	if(vTeacherList.indexOf(strTemp) == -1)
		strFacIndex = (String)vTeacherList.elementAt(0);

	request.setAttribute("fac_index",strFacIndex);

	vSubList = comUtil.getSubjectList(dbOP,request);
	if(vSubList == null)
	{
		if(strErrMsg != null)
			strErrMsg += comUtil.getErrMsg();
		else
			strErrMsg = comUtil.getErrMsg();

		bolFatalErr = true;
	}
}

if(strErrMsg == null) strErrMsg = "&nbsp;";
%>
<form name="form_" method="post" action="./questionnaires_edit.jsp" onSubmit="SubmitOnceButton(this)">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73">
      <td height="25"><div align="center"><strong><font color="#FFFFFF">::::
          QUESTIONNAIRES PAGE - SET PARAMETERS ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><strong><%=strErrMsg%></strong></td>
    </tr>
<%
if(bolFatalErr)
{
	dbOP.cleanUP();
	return;
}%>

    <%
if(vTeacherList != null){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="97%">Questionnaire prepared by(fname,last name)
        <select name="teacher">
          <%
strTemp = WI.fillTextValue("teacher");

for(int i = 0; i< vTeacherList.size(); ++i)
{
	if(strTemp.compareTo((String)vTeacherList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>" selected><%=(String)vTeacherList.elementAt(i)%></option>
          <%}else{%>
          <option value="<%=(String)vTeacherList.elementAt(i++)%>"><%=(String)vTeacherList.elementAt(i)%></option>
          <%}
}%>
        </select>
        </td>
    </tr>
    <tr>
      <td colspan="2" align="center"><input type="submit" name="Submit3" value=" Refresh Page " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.edit_info.value=''"></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
<%
if(vSubList != null){%>
    <tr bgcolor="#DDDDDD">
      <td height="20">&nbsp;</td>
      <td colspan="2" align="center" style="font-size:11px; font-weight:bold; color:#0000CC">::: Edit Basic Information ::: </td>
    </tr>
    <tr>
      <td width="3%" height="20">&nbsp;</td>
      <td width="25%">Name
        of this questionnaire</td>
      <td width="72%">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("qn_name");
%>
        <input type="text" name="qn_name" value="<%=strTemp%>">      </td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Duration of exam</td>
      <td>
<%
int iHour = 0;
int iMin  = 0;
if(vEditInfo != null)
{
	strTemp = (String)vEditInfo.elementAt(4);
	iMin = Integer.parseInt(strTemp);
	iHour = iMin/60;
	iMin = iMin %60;
}
else
{
	iHour = Integer.parseInt(WI.fillTextValue("dur_hour"));
	iMin  = Integer.parseInt(WI.fillTextValue("dur_min"));
}
%>
		<input name="dur_hour" type="text" size="2" value="<%=iHour%>">
        Hours
        <input name="dur_min" type="text" size="2" value="<%=iMin%>">
        Minutes </td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr>
      <td colspan="4"><hr> </td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="25%">Subject
        <strong> </strong></td>
      <td colspan="2"><select name="subject" onChange="ReloadPage();">
<%
if(vEditInfo != null)
	strSubIndex = (String)vEditInfo.elementAt(2);
else
	strSubIndex = WI.fillTextValue("subject");

if(strSubIndex.length() == 0)
	strSubIndex = (String)vSubList.elementAt(0);
for(int i = 0; i< vSubList.size(); ++i)
{
	if(strSubIndex.compareTo((String)vSubList.elementAt(i)) ==0)
	{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>" selected><%=(String)vSubList.elementAt(i)%></option>
    <%}else{%>
          <option value="<%=(String)vSubList.elementAt(i++)%>"><%=(String)vSubList.elementAt(i)%></option>
    <%}
}%>
        </select>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Examination Period</td>
      <td width="45%"><select name="exam_period">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("exam_period");
%>
          <%=dbOP.loadCombo("EPERIOD_INDEX","NAME"," from OLE_EPERIOD where IS_VALID=1 order by name asc",strTemp, false)%>
        </select></td>
      <td width="27%">&nbsp;</td>
    </tr>
	<tr>
		<td></td><td></td>
      <td colspan="2">
	  <input type="submit" name="Submit" value=" Edit Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.edit_info.value='1'">
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr bgcolor="#DDDDDD">
      <td height="20">&nbsp;</td>
      <td colspan="6" align="center" style="font-size:11px; font-weight:bold; color:#0000CC">::: Edit Question Order Information ::: </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Question type</td>
      <td><strong>True/False</strong></td>
      <td><strong>Multiple Choice</strong></td>
      <td><strong>Matching Type</strong></td>
      <td><strong>Objective</strong></td>
      <td><strong>Essay</strong></td>
    </tr>

    <tr>
      <td>&nbsp;</td>
      <td>Test Order </td>
      <td>
<%//System.out.println(vQNOrder);
strTemp = WI.fillTextValue("t_or1");
if(strTemp.length() == 0 && vQNOrder != null && vQNOrder.elementAt(0).equals("1")) {
	strTemp = (String)vQNOrder.elementAt(1);
	vQNOrder.removeElementAt(0);
	vQNOrder.removeElementAt(0);
}
%>        <select name="t_or1">
          <option value="1">I</option>
<%
if(strTemp.equals("2"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="2" <%=strErrMsg%>>II</option>
<%
if(strTemp.equals("3"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="3" <%=strErrMsg%>>III</option>
<%
if(strTemp.equals("4"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="4" <%=strErrMsg%>>IV</option>
<%
if(strTemp.equals("5"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="5" <%=strErrMsg%>>V</option>
        </select>
	  </td>
      <td>
<%
strTemp = WI.fillTextValue("t_or2");
if(strTemp.length() == 0 && vQNOrder != null && vQNOrder.elementAt(0).equals("2")) {
	strTemp = (String)vQNOrder.elementAt(1);
	vQNOrder.removeElementAt(0);
	vQNOrder.removeElementAt(0);
}
%>        <select name="t_or2">
          <option value="1">I</option>
<%
if(strTemp.equals("2"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="2" <%=strErrMsg%>>II</option>
<%
if(strTemp.equals("3"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="3" <%=strErrMsg%>>III</option>
<%
if(strTemp.equals("4"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="4" <%=strErrMsg%>>IV</option>
<%
if(strTemp.equals("5"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="5" <%=strErrMsg%>>V</option>
        </select>
	  </td>
      <td>
<%
strTemp = WI.fillTextValue("t_or3");
if(strTemp.length() == 0 && vQNOrder != null && vQNOrder.elementAt(0).equals("3")) {
	strTemp = (String)vQNOrder.elementAt(1);
	vQNOrder.removeElementAt(0);
	vQNOrder.removeElementAt(0);
}
%>        <select name="t_or3">
          <option value="1">I</option>
<%
if(strTemp.equals("2"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="2" <%=strErrMsg%>>II</option>
<%
if(strTemp.equals("3"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="3" <%=strErrMsg%>>III</option>
<%
if(strTemp.equals("4"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="4" <%=strErrMsg%>>IV</option>
<%
if(strTemp.equals("5"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="5" <%=strErrMsg%>>V</option>
        </select>
      </td>
      <td>
<%
strTemp = WI.fillTextValue("t_or4");
if(strTemp.length() == 0 && vQNOrder != null && vQNOrder.elementAt(0).equals("4")) {
	strTemp = (String)vQNOrder.elementAt(1);
	vQNOrder.removeElementAt(0);
	vQNOrder.removeElementAt(0);
}
%>        <select name="t_or4">
          <option value="1">I</option>
<%
if(strTemp.equals("2"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="2" <%=strErrMsg%>>II</option>
<%
if(strTemp.equals("3"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="3" <%=strErrMsg%>>III</option>
<%
if(strTemp.equals("4"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="4" <%=strErrMsg%>>IV</option>
<%
if(strTemp.equals("5"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="5" <%=strErrMsg%>>V</option>
        </select>
	  </td>
      <td>
<%
strTemp = WI.fillTextValue("t_or5");
if(strTemp.length() == 0 && vQNOrder != null && vQNOrder.elementAt(0).equals("5")) {
	strTemp = (String)vQNOrder.elementAt(1);
	vQNOrder.removeElementAt(0);
	vQNOrder.removeElementAt(0);
}
%>        <select name="t_or5">
          <option value="1">I</option>
<%
if(strTemp.equals("2"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="2" <%=strErrMsg%>>II</option>
<%
if(strTemp.equals("3"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="3" <%=strErrMsg%>>III</option>
<%
if(strTemp.equals("4"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="4" <%=strErrMsg%>>IV</option>
<%
if(strTemp.equals("5"))	strErrMsg = "selected";
else strErrMsg = "";
%>          <option value="5" <%=strErrMsg%>>V</option>
        </select>
	 </td>
    </tr>
    <tr>
      <td width="2%" height="20">&nbsp;</td>
      <td width="13%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td width="15%"><input type="submit" name="Submit" value=" Edit Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.edit_info.value='2'"></td>
      <td width="15%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" id="myADTable1" onClick="findRowNumber(event.target||event. srcElement);">
    <tr bgcolor="#DDDDDD">
      <td height="20">&nbsp;</td>
      <td colspan="5" align="center" style="font-size:11px; font-weight:bold; color:#0000CC">::: Edit Question Points ::: </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px; font-weight:bold">Chapter/Sub Chapter </td>
      <td style="font-size:10px; font-weight:bold">Domain</td>
      <td style="font-size:10px; font-weight:bold">Question Type</td>
      <td style="font-size:10px; font-weight:bold"># of Questions </td>
      <td style="font-size:10px; font-weight:bold">Remove</td>
    </tr>

<%for(int i = 0, iRowCount=0; i < vQuestionDistribution.size(); i += 8, ++iRowCount){%>
    <tr>
      <td height="20">&nbsp;</td>
      <td style="font-size:11px;"><%=vQuestionDistribution.elementAt(i + 4)%>. <%=vQuestionDistribution.elementAt(i + 5)%>
	  <%if(vQuestionDistribution.elementAt(i + 6) != null) {%><br>
	  <%=vQuestionDistribution.elementAt(i + 6)%>. <%=vQuestionDistribution.elementAt(i + 7)%>
	  <%}%></td>
      <td style="font-size:11px;"><%=vQuestionDistribution.elementAt(i + 1)%></td>
      <td style="font-size:11px;"><%=vQuestionDistribution.elementAt(i + 2)%></td>
      <td style="font-size:11px;"><%=vQuestionDistribution.elementAt(i + 3)%></td>
      <td style="font-size:11px;"><a href="javascript:RemoveQPoints('<%=vQuestionDistribution.elementAt(i)%>','_<%=i%>',document.form_._<%=vQuestionDistribution.elementAt(i)%>);">Remove</a>
      <input type="text" class="textbox_noborder" style="font-size:9px;" name="_<%=vQuestionDistribution.elementAt(i)%>" size="7"></td>
    </tr>
<%}%>
    <tr>
      <td height="20">&nbsp;</td>
      <td colspan="2" align="right"><input type="submit" name="Submit2" value=" Add more Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.add_more.value='1'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="20" width="4%">&nbsp;</td>
      <td width="50%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="14%">&nbsp;</td>
    </tr>
<%if(WI.fillTextValue("add_more").length() > 0) {
String strChapterCode  = null;
String strSubTopicCode = null;
Vector vNoOfQues = null;
int iTFPoints = 0;
%>
    <tr>
      <td height="20" colspan="6">
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="1" cellpadding="1">
			<tr>
			  <td width="3%" height="23">&nbsp;</td>
			  <td width="97%">Chapter
				<select name="chapter" onChange="document.form_.add_more.value='1';document.form_.submit();">
				  <%
		String strTemp2 = "";
		strTemp =WI.fillTextValue("chapter");
		vTemp = comUtil.getChapterList(dbOP, strSubIndex);
		if(vTemp == null) vTemp = new Vector();
		for(int i = 0; i< vTemp.size(); ++i)
		{
			if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
			{
				strTemp2 = (String)vTemp.elementAt(i+2);
				%>
				  <option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
				  <%}else{%>
				  <option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
				  <%}
		}
		if(strTemp2.length() ==0 && vTemp.size() > 0)//this is the first time, so take the first chapter in the list
		{
			strTemp = (String)vTemp.elementAt(1);//chapter code.;
			strTemp2 = (String)vTemp.elementAt(2);
		}
		strChapterCode = strTemp;
		%>
				</select> &nbsp; Name:<strong> <%=strTemp2%></strong></td>
			</tr>
			<tr>
			  <td height="23">&nbsp;</td>
			  <td>Subtopic order
				<select name="sub_topic" onChange="document.form_.add_more.value='1';document.form_.submit();">
				  <option value="0">Select a Subtopic</option>
				  <%
		vTemp = comUtil.getSubChapterList(dbOP, strTemp, strTemp2,strSubIndex);
		if(vTemp == null) vTemp = new Vector();
		strTemp2 = "";
		strTemp =WI.fillTextValue("sub_topic");
		for(int i = 0; i< vTemp.size(); ++i)
		{
			if(strTemp.compareTo((String)vTemp.elementAt(i+1)) ==0)
			{
				strTemp2 = (String)vTemp.elementAt(i+2);
				%>
				  <option value="<%=(String)vTemp.elementAt(++i)%>" selected><%=(String)vTemp.elementAt(i++)%></option>
				  <%}else{%>
				  <option value="<%=(String)vTemp.elementAt(++i)%>"><%=(String)vTemp.elementAt(i++)%></option>
				  <%}
		}
		if(strTemp2.length() ==0 && vTemp.size() > 0)//this is the first time, so take the first chapter in the list
		{
			strTemp = (String)vTemp.elementAt(1);//chapter code.;
			strTemp2 = (String)vTemp.elementAt(2);
		}
		if(strTemp == null || strTemp.trim().length() ==0 || strTemp.compareTo("0") ==0)
			strSubTopicCode = null;
		else
			strSubTopicCode = strTemp;

		%>
				</select> &nbsp; Name:<strong> <%=strTemp2%></strong></td>
			</tr>
			<tr>
			  <td height="23">&nbsp;</td>
			  <td>Total questions available for this chapter :
				<%
		vNoOfQues = comUtil.noOfQuesInChapter(dbOP, strChapterCode, strSubIndex, strSubTopicCode);
		if(vNoOfQues == null){%>
				<%=comUtil.getErrMsg()%>
				<%}else{%>
				T/F=<b><%=(String)vNoOfQues.elementAt(0)%></b>, M/C=<b><%=(String)vNoOfQues.elementAt(1)%></b>,
				M/T=<b><%=(String)vNoOfQues.elementAt(2)%></b>, OBJ=<b><%=(String)vNoOfQues.elementAt(3)%></b>,
				ESS=<b><%=(String)vNoOfQues.elementAt(4)%></b>
				<%}%>
			  </td>
			</tr>
  </table>
		<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborderALL">
			<tr>
			  <td width="3%">&nbsp;</td>
			  <td colspan="7">NOTE : To build questionnaire please set total no of question
				for in a domain of learning for a Question type.</td>
			</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td></td>
		<%vTemp = comUtil.getDOLIndex(dbOP);
		for(int i = 0; i< vTemp.size(); ++i){%>
			  <td><strong><%=(String)vTemp.elementAt(++i)%></strong></td>
		<%}%>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td>True or False</td>
		<%
		for(int i = 0; i< vTemp.size(); ++i){
		strTemp = "1_"+(String)vTemp.elementAt(i++);
		%>
			  <td><input type="text" name="<%=strTemp%>" size="2" onKeyUp='TotalPoints("<%=iTFPoints%>","<%=strTemp%>");' value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
		<%}%>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td>Multiple Choice</td>
		<%
		for(int i = 0; i< vTemp.size(); ++i){
		strTemp = "2_"+(String)vTemp.elementAt(i++);
		%>
			  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
		<%}%></tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td>Matching Type</td>
		<%
		for(int i = 0; i< vTemp.size(); ++i){
		strTemp = "3_"+(String)vTemp.elementAt(i++);
		%>
			  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
		<%}%>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td>Objectives</td>
		<%
		for(int i = 0; i< vTemp.size(); ++i){
		strTemp = "4_"+(String)vTemp.elementAt(i++);
		%>
			  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
		<%}%>
		</tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td>Essay</td>
		<%
		for(int i = 0; i< vTemp.size(); ++i){
		strTemp = "5_"+(String)vTemp.elementAt(i++);
		%>
			  <td><input type="text" name="<%=strTemp%>" size="2" value="<%=WI.fillTextValue(strTemp)%>" maxlength="3"></td>
		<%}%>
		</tr>
		<tr>
		  <td>&nbsp;</td>
		  <td align="center"><input type="submit" name="Submit22" value=" Save Information " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.edit_info.value='3'"></td>
		  <td>&nbsp;</td>
		  </tr>
		</table>	  </td>
    </tr>
<%}%>
  </table>

<%
	} //if vTeacherList == null
}//if vSubList == null
%>
<input type="hidden" name="edit_info">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="add_more">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
