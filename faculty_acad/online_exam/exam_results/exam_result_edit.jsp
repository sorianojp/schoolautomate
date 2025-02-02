<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/maintenancelinkscss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function AddRecord()
{
	document.question.addRecord.value =1;
	document.question.reloadPage.value =0;
	
}
function ReloadPage()
{
	document.question.addRecord.value =0;
	document.question.reloadPage.value =1;
	
	document.question.submit();
	
}



</script>
<body bgcolor="A27D3E">
<%@ page language="java" import="utility.*,Question,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
//add security here.
request.getSession(false).setAttribute("userId","biswa");
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		//exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code. 
Question ques = new Question();

//check for add - edit or delete 
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	//add it here and give a message.
	if(ques.add(dbOP,request))
	{
		strErrMsg = "Question added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
		<%=ques.getErrMsg()%></font></p>
		<%
		return;
	}
}

%>
<form name="question" method="post" action="../../ADMISSION%20MAINTENANCE%20MODULE/one%20files/QUESTION%20BANK/./admission_question_add.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="88%" height="25" colspan="8"><div align="center"><strong> <font color="#FFFFFF" > 
          </font><font color="#FFFFFF" size="2" >:::: EXAM RESULTS - EDIT RESULTS 
          PAGE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <%
if(strErrMsg == null) strErrMsg = "";
%>
      <td colspan="4"> <font size="3" face="Verdana, Arial, Helvetica, sans-serif"><strong><%=strErrMsg%></strong></font></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="3">College of 
        <select name="select4">
        </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="35%" valign="bottom" >Subject</td>
      <td width="20%">&nbsp;</td>
      <td width="42%">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" ><select name="select">
          <option>Select</option>
        </select> <input name="textfield2" type="text" size="64"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom" >Section</td>
      <td valign="bottom" >Examination Period </td>
      <td valign="bottom" >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td ><font color="#000000" size="2"> 
        <select name="select5">
          <option>Select</option>
        </select>
        </font></td>
      <td ><select name="select2">
        </select></td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td ><font color="#000000" size="2">&nbsp; </font></td>
      <td ><img src="../../../images/form_proceed.gif" width="81" height="21"></td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4"><hr></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="bottom" >Date of Examination</td>
      <td valign="bottom" >Time of Examination</td>
      <td valign="bottom" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="21">&nbsp;</td>
      <td ><input name="textfield" type="text" size="2">
        / 
        <input name="textfield3" type="text" size="2">
        / 
        <input name="textfield32" type="text" size="4"> <font size="1">(mm/dd/yyyy)</font></td>
      <td colspan="2" ><input name="textfield4" type="text" size="2">
        : 
        <input name="textfield5" type="text" size="2"> <select name="select3">
          <option>AM</option>
          <option>PM</option>
        </select>
        to 
        <input name="textfield42" type="text" size="2">
        : 
        <input name="textfield52" type="text" size="2"> <select name="select6">
          <option>AM</option>
          <option>PM</option>
        </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td valign="bottom">Duration of the exam</td>
      <td valign="bottom">Room #</td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><input name="textfield43" type="text" size="2">
        Hours 
        <input name="textfield53" type="text" size="2">
        Minutes</td>
      <td><select name="select7">
        </select></td>
      <td >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font color="#000000" size="2">Total points for this exam : 
        <input name="textfield6" type="text" size="3">
        </font></td>
      <td colspan="2">Total students taking this exam : <font color="#000000" size="2"> 
        <input name="textfield62" type="text" size="3">
        </font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td  colspan="2"><strong> </strong></td>
      <td >&nbsp;</td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" colspan="2" bgcolor="#B9B292"><div align="center">EXAMINATION 
          RESULT FOR SUBJECT <strong>$subject </strong>SECTION <strong>$section</strong> 
          FOR <strong>$exam_period</strong> EXAMINATION</div></td>
    </tr>
  </table>
	
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="12%" height="21" rowspan="2"><div align="center"><font size="1">STUDENT 
          ID</font></div></td>
      <td width="23%" rowspan="2"><div align="center"><font size="1">STUDENT NAME</font></div></td>
      <td width="30%" rowspan="2"><div align="center"><font size="1">COURSE/MAJOR</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">YEAR</font></div></td>
      <td colspan="5" width="20%"><div align="center"><font size="1">SCORE</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">TOTAL SCORE</font></div></td>
      <td width="5%" rowspan="2"><div align="center"><font size="1">PERCENT-AGE 
          (%) </font></div></td>
    </tr>
    <tr> 
      <td width="4%"><div align="center">I</div></td>
      <td width="4%"><div align="center">II</div></td>
      <td width="4%"><div align="center">III</div></td>
      <td width="4%"><div align="center">IV</div></td>
      <td width="4%"><div align="center">V</div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp; 
        <input name="textfield7" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield72" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield73" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield74" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield75" type="text" size="3">
        </font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp; 
        <input name="textfield7" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield72" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield73" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield74" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield75" type="text" size="3">
        </font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp; 
        <input name="textfield7" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield72" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield73" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield74" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield75" type="text" size="3">
        </font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><font size="1">&nbsp; 
        <input name="textfield7" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield72" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield73" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield74" type="text" size="3">
        </font></td>
      <td><font size="1"> 
        <input name="textfield75" type="text" size="3">
        </font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="71%" height="25"><div align="center"><img src="../../../images/save.gif" width="48" height="28"><font size="1">click 
          to save changes</font></div></td>
      <td width="29%">&nbsp;</td>
    </tr>
  </table>


  <%
strTemp = request.getParameter("q_type_index");
if(strTemp != null && strTemp.compareTo("selectany") != 0)
{//display input for answer and question depending on the question type.
%>
  <table bgcolor="#FFFFFF" width="100%">
    <tr> 
      <td width="100%" colspan="3">&nbsp;</td>
    </tr>
  </table>
 <%
 }//end of showing question and answer options. 
 %>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<!-- all hidden fields go here -->
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="reloadPage" value="0">

 </form>
</body>
</html>
