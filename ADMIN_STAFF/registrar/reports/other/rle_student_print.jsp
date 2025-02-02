<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function UpdateGrade(strGSIndex, strGrade) {//alert(" change here. "+strGSIndex);
	if(strGSIndex == '')
		return;
	if(strGrade != 'null')
		return;
	//alert(" change here. ");
	var vNewGrade = prompt("Please enter new grade : ","New Grade");
	if(vNewGrade == null)
		return;
	document.form_.gs_index.value = strGSIndex;
	document.form_.new_grade.value = vNewGrade;
	document.form_.submit();
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
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
String strStudID = WI.fillTextValue("stud_id");
String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");

//I have to findout if grade is changed, if it is changed, i must update it. 
if(WI.fillTextValue("gs_index").length() > 0 && WI.fillTextValue("new_grade").length() > 0) {
	try {
		Double.parseDouble(WI.fillTextValue("new_grade"));
		strTemp = "update g_sheet_final set grade = "+WI.fillTextValue("new_grade")+" where gs_index = "+
			WI.fillTextValue("gs_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}
	catch(Exception e) {strErrMsg = "Please enter grade in correct format.";}
}

Vector vRetResult  = null;
Vector vRLESubList = null;
Vector vSubList    = null;
String strGradeAvg = null; String strTotalDutyHr = null;
if(strStudID.length() > 0 && strSYFrom.length() > 0 && strSem.length() > 0) {
	RLEInformation rleInfo = new RLEInformation();
	vRetResult = rleInfo.printRLE(dbOP, strStudID); 
	if(vRetResult == null)
		strErrMsg = rleInfo.getErrMsg();
	else {
		vRLESubList = (Vector) vRetResult.remove(0);
		vSubList    = (Vector) vRetResult.remove(0);
		strTotalDutyHr = (String)vSubList.remove(0);
		strGradeAvg = (String)vSubList.remove(0);
	}
}

java.sql.ResultSet rs = null;
String strCONDean = dbOP.getResultOfAQuery("select DEAN_NAME from college where c_name = 'College of Nursing'",0);
 

if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:11px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();
return;}%>
<form name="form_" action="./rle_student_print.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2">
	  	<div align="center"><font size="4">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br></div>
	  </td>
    </tr>
  </table>
  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
	<tr>
		<td height="25" colspan="2" align="center" style="font-weight:bold; font-size:13px;">
			SUMMARY OF RELATED LEARNING EXPERIENCE</td>   
	</tr>
    <tr>
      <td width="74%" height="25" >Name : <font style="font-size:14px;"><%=CommonUtil.getName(dbOP, WI.fillTextValue("stud_id"), 4).toUpperCase()%></font></td>
      <td width="26%" align="center">&nbsp;&nbsp;Class : <%=Integer.parseInt(WI.fillTextValue("sy_from"))+1%></td>
    </tr>
    <tr>
      <td height="10" >&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
  </table>
  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1" class="thinborderALL">
    <tr style="font-weight:bold">
      <td width="55%" height="20" align="center" class="thinborderBOTTOMRIGHT">COURSE</td>
      <td width="15%" align="center" class="thinborderBOTTOMRIGHT">No of Hours </td>
      <td width="15%" class="thinborderBOTTOMRIGHT">&nbsp;</td>
      <td width="15%" align="center" class="thinborderBOTTOM">Grades</td>
    </tr>
<%
int iIndexOf = 0; String strSubIndex = null;
String[] astrConvertPoint = {"I.","II.","III.","IV.","V.","VI.","VII.","VIII.","IX.","X.","XI."};
boolean bolIsLast = false;
for(int i = 0, iCount=0; i < vRLESubList.size(); ){
	strSubIndex = (String)vRLESubList.elementAt(i);
	iIndexOf = vSubList.indexOf(strSubIndex);
	//iCount = 0;
%>
    <tr style="font-weight:bold">
      <td height="20" class="thinborderRIGHT"><%=astrConvertPoint[iCount++]%><%=vRLESubList.elementAt(i + 1)%></td>
      <td class="thinborderRIGHT">&nbsp;</td>
      <td class="thinborderRIGHT" align="center">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(iIndexOf*5 + 3), false)%></td>
      <td class="thinborderNONE" align="center">&nbsp;<u>
	  	<label id="change_grade<%=iCount%>" onDblClick="UpdateGrade('<%=vRetResult.elementAt(iIndexOf*5 + 4)%>','<%=vRetResult.elementAt(iIndexOf*5)%>');"><%=vRetResult.elementAt(iIndexOf*5)%></label><!-- on double click allow to change grade -->
		</u></td>
    </tr>
<%for(;i < vRLESubList.size() && strSubIndex.equals(vRLESubList.elementAt(i)); i += 4){
if( (i + 5) > vRLESubList.size())
	bolIsLast = true;
else if(!strSubIndex.equals(vRLESubList.elementAt(i +4)) )
		bolIsLast = true;
else	
	bolIsLast = false;
%>
    <tr>
      <td height="20" class="thinborderRIGHT">&nbsp;&nbsp;&nbsp;&nbsp;<%=vRLESubList.elementAt(i + 2)%></td>
      <td align="center" class="thinborderRIGHT">&nbsp;
	  	<%if(bolIsLast){%><u><%}%><%=vRLESubList.elementAt(i + 3)%><%if(bolIsLast){%></u><%}%></td>
      <td class="thinborderRIGHT">&nbsp;</td>
      <td class="thinborderNONE">&nbsp;</td>
    </tr>
<%}//end of inner for loop.

}//end of outer for loop.%>
    <tr>
      <td height="20" class="thinborderRIGHT">&nbsp;</td>
      <td align="center" class="thinborderRIGHT">&nbsp;</td>
      <td class="thinborderTOPRIGHT" align="center">Total : <%=strTotalDutyHr%> hrs</td>
      <td class="thinborderTOP">Gen. Avg. <b><%=strGradeAvg%></b></td>
    </tr>
  </table>
  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td width="30%" height="34" class="thinborderNONE" valign="top">* No. of Delivery Cases 
	  <br> 
	  Handled &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <u>&nbsp;&nbsp;5&nbsp;&nbsp;</u>
	  <br> Assisted &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <u>&nbsp;&nbsp;5&nbsp;&nbsp;</u>
	  <br> Cord Care &nbsp;&nbsp; <u>&nbsp;&nbsp;5&nbsp;&nbsp;</u>	  </td>
      <td width="30%" class="thinborderNONE" valign="top">** No. Of OR Cases  
	    <br>
Major Scrubs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <u>&nbsp;&nbsp;5&nbsp;&nbsp;</u> <br>
Minor Scrubs&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <u>&nbsp;&nbsp;5&nbsp;&nbsp;</u></td>
      <td width="40%" class="thinborderNONE" valign="bottom" align="center"><u><b><br><br><br><br><%=WI.getStrValue(strCONDean).toUpperCase()%></b></u><br><b>Dean</b></td>
    </tr>
  </table>
<DIV style="page-break-before:always">&nbsp;</DIV>
  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr style="font-weight:bold">
      <td width="55%" height="34" align="center" class="thinborderNONE" valign="top"><u>AFFILIATING AGENCIES</u></td>
      <td width="45%" align="center" class="thinborderNONE" valign="top"><u>CHIEF NURSE</u></td>
    </tr>

<%
//I have to get here affiliation information.. 
Vector vAffAgency = new Vector();
for(int i =0; i < vRLESubList.size(); i += 4) {
strSubIndex = (String)vRLESubList.elementAt(i);
iIndexOf = vSubList.indexOf(strSubIndex);
//System.out.println(vRetResult.elementAt(iIndexOf * 4));
//System.out.println(vRetResult.elementAt(iIndexOf * 4 + 1));
//System.out.println(vRetResult.elementAt(iIndexOf * 4 + 2));
	rs = dbOP.executeQuery("select AFF_NAME,WARD_INFO,CHIEFNURSE from RLE_AFFILIATION "+
		"join RLE_SUB_AFFILIATED on (RLE_SUB_AFFILIATED.aff_index = rle_affiliation.aff_index) where "+
		"SUB_INDEX = "+(String)vSubList.elementAt(iIndexOf)+" and RLE_SUB_AFFILIATED.SY_FROM = "+
		vRetResult.elementAt(iIndexOf * 4 + 1)+
		" and RLE_SUB_AFFILIATED.SEMESTER = "+vRetResult.elementAt(iIndexOf * 4 + 2)); 
	while(rs.next()) {
		if(vAffAgency.indexOf(rs.getString(1)) > -1)
			continue;
		vAffAgency.addElement(rs.getString(1));%>
    <tr>
      <td width="55%" height="20" align="center" class="thinborderNONE" valign="top"><b><u><%=rs.getString(1)%></u></b> <br>
	  <%=ConversionTable.replaceString(rs.getString(2),"\r\n","<br>")%></td>
      <td width="45%" align="center" class="thinborderNONE" valign="top"><b><u><%=rs.getString(3)%></u></b></td>
    </tr>
    <tr>
      <td height="20" align="center" class="thinborderNONE" colspan="2">&nbsp;</td>
    </tr>
	<%}rs.close();%>
<%}%>
</table>
<input type="hidden" name="gs_index">
<input type="hidden" name="new_grade">

<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
