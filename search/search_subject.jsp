<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg()
{
	document.search.printPg.value=1;
	document.search.submit();
}
</script>

<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
dbOP.cleanUP();
ConstructSearch constSearch = new ConstructSearch();

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};

%>
<form action="./search_subject.jsp" method="post" name="search">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SEARCH SUBJECT PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%">Subject Code</td>
      <td width="79%"><select name="sub_code_con">
 <%=constSearch.constructGenericDropList(WI.fillTextValue("sub_code_con"),astrDropListEqual,astrDropListValEqual)%>
        </select> <input type="text" name="sub_code"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject Title/Name</td>
      <td><select name="select7">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input type="text" name="sub_name"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject Category</td>
      <td><select name="select2">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input type="text" name="catg_name"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject Group</td>
      <td><select name="select2">
          <option>Equal to</option>
          <option>Starts with</option>
          <option>Ends with</option>
          <option>Contains</option>
        </select> <input type="text" name="group_name"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Min. no. of students </td>
      <td><select name="select3">
          <option>Equal to</option>
          <option>Less than</option>
          <option>More than</option>
        </select>
        <input name="min_stud_from" type="text" size="3">
        <select name="select5">
          <option>Equal to</option>
          <option>Less than</option>
          <option>More than</option>
        </select> <input name="min_stud_to" type="text" size="3"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Max. no. of students </td>
      <td><select name="select6">
          <option>Equal to</option>
          <option>Less than</option>
          <option>More than</option>
        </select> <input name="max_stud_fr" type="text" size="3"> <select name="select6">
          <option>Equal to</option>
          <option>Less than</option>
          <option>More than</option>
        </select> <input name="max_stud_to" type="text" size="3"> </td>
    </tr>
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option>Subject Code</option>
          <option>Subject Title/Name</option>
          <option>Subject Category</option>
          <option>Subject Group</option>
          <option>Min. no. of students</option>
          <option>Max. no. of students</option>
        </select>
      </td>
      <td width="25%"><select name="sort_by2">
          <option>Subject Code</option>
          <option>Subject Title/Name</option>
          <option>Subject Category</option>
          <option>Subject Group</option>
          <option>Min. no. of students</option>
          <option>Max. no. of students</option>
        </select> </td>
      <td width="39%"><select name="sort_by3">
          <option>Subject Code</option>
          <option>Subject Title/Name</option>
          <option>Subject Category</option>
          <option>Subject Group</option>
          <option>Min. no. of students</option>
          <option>Max. no. of students</option>
        </select> </td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="select9">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
      <td><select name="select10">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
      <td><select name="select11">
          <option>Ascending</option>
          <option>Descending</option>
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" src="../images/form_proceed.gif" width="81" height="21"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" width="58" height="26" border="0"></a>
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH
          RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="54%" height="25"><b>Total Result :</b></td>
      <td width="15%"><div align="right"><img src="../images/form_proceed.gif" width="81" height="21"></div></td>
      <td width="31%"><div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">
           
          </select>
          
        </div></td>
    </tr>
  </table>


  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="13%" height="25"><div align="center"><font size="1"><strong>SUBJECT
          CODE </strong></font></div></td>
      <td width="32%"><div align="center"><font size="1"><strong>SUBJECT NAME
          </strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>SUBJECT CATEGORY
          </strong></font></div></td>
      <td width="12%" align="center"><strong><font size="1">SUBJECT GROUP</font></strong></td>
      <td width="5%"><div align="center"><font size="1"><strong>MIN STUD </strong></font></div></td>
      <td width="5%" align="center"><strong><font size="1">MAX STUD</font></strong></td>
    </tr>
    
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="69%" height="25"><div align="right"><img src="../images/form_proceed.gif" width="81" height="21"></div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
  </table>

<input type="hidden" name="printPg">
</form>
</body>
</html>
