<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function showHideGWA() {
	var iSelGwaCon = document.form_.gwa_con.selectedIndex;
	if(iSelGwaCon == 0) {
		hideLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
		
		document.form_.gwa_fr.value='';
		document.form_.gwa_to.value='';
		
	}
	else if(iSelGwaCon == 3) {
		showLayer('gwa_fr_label');
		showLayer('gwa_to_label');
	}
	else {
		showLayer('gwa_fr_label');
		hideLayer('gwa_to_label');
		
		document.form_.gwa_to.value='';
	}
}
</script>
<body bgcolor="#D2AE72" onLoad="showHideGWA(); document.form_.report_name.focus();">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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
Vector vRetResult = null;
Vector vEditInfo  = null;

student.GWA gwa = new student.GWA();
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(gwa.operateOnPreloadGWASetting(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = gwa.getErrMsg();
	else {
		strErrMsg = "Operation Successful";
		strPreparedToEdit = "0";
	}
}
if(strPreparedToEdit.equals("1"))
	vEditInfo = gwa.operateOnPreloadGWASetting(dbOP, request, 3);
	
vRetResult = gwa.operateOnPreloadGWASetting(dbOP, request, 4);
%>

<form name="form_" action="./gwa_setting_preload.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" align="center"><font color="#FFFFFF"><strong>:::: 
        GWA GRADE EQUIVALENT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="2" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
else
	strTemp = WI.fillTextValue("report_name");
%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" class="thinborderNONE">Report Name </td>
      <td width="83%" ><input name="report_name" type="text" size="60" maxlength="128" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td class="thinborderNONE">1. Show GWA </td>
      <td class="thinborderNONE"><select name="gwa_con" onChange="showHideGWA();">
          <option value="0">No Filter</option>
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
else
	strTemp = WI.fillTextValue("gwa_con");

if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>Greater than</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="2"<%=strErrMsg%>>Less than</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>          <option value="3"<%=strErrMsg%>>Between</option>
        </select>
&nbsp;&nbsp;&nbsp;
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
else
	strTemp = WI.fillTextValue("gwa_fr");
%>
      <input name="gwa_fr" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_fr');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_fr');" style="font-size:12px" id="gwa_fr_label">
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
else
	strTemp = WI.fillTextValue("gwa_to");
%>

<label id="gwa_to_label">
&nbsp;&nbsp;to&nbsp;&nbsp;
      <input name="gwa_to" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','gwa_to');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','gwa_to');" style="font-size:12px" >
</label>		</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td class="thinborderNONE">2. Student with Min Unit? </td>
      <td class="thinborderNONE">
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
else
	strTemp = WI.fillTextValue("min_unit");
%>
	          <input name="min_unit" type="text" size="3" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','min_unit');style.backgroundColor='white'"
		onKeyup="AllowOnlyInteger('form_','min_unit');" style="font-size:12px" >
&nbsp;&nbsp;&nbsp;&nbsp;3. Students with  Final Grade:
<select name="final_grade_con">
  <option value="0">Greater than</option>
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
else
	strTemp = WI.fillTextValue("final_grade_con");
if(strTemp.equals("1"))
	strTemp = " selected";
else
	strTemp = "";
%>  <option value="1"<%=strTemp%>>Less than</option>
</select> 
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
else
	strTemp = WI.fillTextValue("final_grade");
%>
      <input name="final_grade" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','final_grade');style.backgroundColor='white'"
		onKeyup="AllowOnlyFloat('form_','final_grade');" style="font-size:12px" >		</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" class="thinborderNONE">4. 
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
else
	strTemp = WI.fillTextValue("remove_fg");

if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>		
        <input type="checkbox" name="remove_fg" value="1" <%=strTemp%>>
        Show Student with all passing grade 
&nbsp;&nbsp;&nbsp;
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(9));
else
	strTemp = WI.fillTextValue("remove_ir");

if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>		
5. 
<input type="checkbox" name="remove_ir" value="1" <%=strTemp%>>
Remove Irregular student	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" class="thinborderNONE">5.
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(11));
else
	strTemp = WI.fillTextValue("get_acad_scholar");

if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="get_acad_scholar" value="1" <%=strTemp%>>
Compute Academic Scholar 
&nbsp;&nbsp;&nbsp;
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(12));
else
	strTemp = WI.fillTextValue("donot_apply_unit_rule");

if(strTemp.equals("1"))
	strTemp = "checked";
else	
	strTemp = "";
%>
6.
<input type="checkbox" name="donot_apply_unit_rule" value="1" <%=strTemp%>>
Do not apply Curriculum Unit rule </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" class="thinborderNONE">
	  	  Order by(GWA) : 
<%
if(vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(10));
else
	strTemp = WI.fillTextValue("order_by");

if(strTemp.equals("asc") || strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="order_by" type="radio" value="asc"<%=strErrMsg%>>Asc
&nbsp;
<%
if(strTemp.equals("desc")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	   <input name="order_by" type="radio" value="desc"<%=strErrMsg%>>
Desc		  
&nbsp;&nbsp;&nbsp; 

Student Name : 
<%
if(strTemp.equals("asc2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input name="order_by" type="radio" value="asc2"<%=strErrMsg%>>Asc&nbsp;
      <%
if(strTemp.equals("desc2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	   <input name="order_by" type="radio" value="desc2"<%=strErrMsg%>>Desc</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td class="thinborderNONE">&nbsp;
<%if(strPreparedToEdit.equals("0")){%>
	  <input type="image" src="../../../images/save.gif" border="0" onClick="document.form_.page_action.value=1"> Click to save information.
<%}else{%>
	  &nbsp;<input type="image" src="../../../images/edit.gif" border="0" onClick="document.form_.page_action.value=2; document.form_.info_index.value='<%=vEditInfo.elementAt(0)%>'"> Click to Edit information.
	  &nbsp;<a href="./gwa_setting_preload.jsp"><img src="../../../images/cancel.gif" border="0"></a> Click to Cancel.
<%}%>	  </td>
    </tr>
    
    <tr> 
      <td colspan="3" height="10" >&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC" style="font-weight:bold">
      <td width="25%" height="25" class="thinborder">&nbsp;Report Name </td>
      <td width="10%" class="thinborder">GWA Condition </td>
      <td width="5%" class="thinborder">Min. Units </td>
      <td width="5%" class="thinborder">Final Grade Condition </td>
      <td width="5%" class="thinborder">Show Stud with Passing Grade </td>
      <td width="5%" class="thinborder">Remove Irregular Stud </td>
      <td width="5%" class="thinborder">Order by</td>
      <td width="5%" class="thinborder">Get Acad Scholar </td>
      <td width="5%" class="thinborder">Do not apply Unit Rule </td>
      <td width="5%" class="thinborder">Edit</td>
      <td width="5%" class="thinborder">&nbsp;Remove </td>
    </tr>
<%
String[] astrConvertGradeFilter = {"No Filter","GWA Greater than ","GWA Less than ","Between"};
String[] astrConvertFinalGrade  = {"Greater than ","Less than "};

for(int i =0; i < vRetResult.size(); i += 13){
strTemp = (String)vRetResult.elementAt(i + 2);
if(strTemp == null)
	strTemp = "Not set";
else {
	if(strTemp.equals("3"))
		strTemp = "GWA Between "+vRetResult.elementAt(i + 3) + " and "+vRetResult.elementAt(i + 4);
	else	
	 	strTemp = astrConvertGradeFilter[Integer.parseInt(strTemp)]+vRetResult.elementAt(i + 3);
}
strErrMsg = (String)vRetResult.elementAt(i + 6);
if(vRetResult.elementAt(i + 7) != null)
	strErrMsg = astrConvertFinalGrade[Integer.parseInt(strErrMsg)]+ vRetResult.elementAt(i + 7);
else	
	strErrMsg = "Not set";%>
    <tr >
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=strErrMsg%></td>
      <td class="thinborder" align="center"><%if(vRetResult.elementAt(i + 8) != null) {%>Yes<%}%>&nbsp;</td>
      <td class="thinborder" align="center"><%if(vRetResult.elementAt(i + 9) != null) {%>Yes<%}%>&nbsp;</td>
<%
strTemp = (String)vRetResult.elementAt(i + 10);
if(strTemp != null) {
	if(strTemp.equals("asc"))
		strTemp = "GWA asc";
	else if(strTemp.equals("desc"))
		strTemp = "GWA desc";
	else if(strTemp.equals("asc2"))
		strTemp = "Name asc";
	else if(strTemp.equals("desc2"))
		strTemp = "Name desc";
}%>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder" align="center"><%if(vRetResult.elementAt(i + 11) != null) {%>Yes<%}%>&nbsp;</td>
      <td class="thinborder" align="center"><%if(vRetResult.elementAt(i + 12) != null) {%>Yes<%}%>&nbsp;</td>
      <td class="thinborder"><input name="image" type="image" 
		onClick="document.form_.page_action.value='';document.form_.info_index.value=<%=vRetResult.elementAt(i)%>;document.form_.preparedToEdit.value='1'" src="../../../images/edit.gif"></td>
      <td class="thinborder">&nbsp;
	  	<input type="image" src="../../../images/delete.gif" 
		onClick="document.form_.page_action.value=0;document.form_.info_index.value=<%=vRetResult.elementAt(i + 1)%>"></td>
    </tr>
<%}%>
  </table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
