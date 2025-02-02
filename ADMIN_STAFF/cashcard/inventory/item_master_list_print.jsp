<%@ page language="java" import="utility.*,java.util.Vector,  hmsOperation.RestItems" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css" />
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css" />
<title>Untitled Document</title>
<script language="JavaScript" src="../../../jscript/common.js" type="text/javascript"></script>
</head>
</html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
</head>
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
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//end of authenticaion code.
	RestItems restItems = new RestItems();
	Vector vRetResult = null;
	int iSearchResult = 0;
	int i = 0;
	boolean bolPageBreak = false;
	vRetResult = restItems.operateOnInventoryItems(dbOP,request,4);

	if (vRetResult != null) {
	
		int iPage = 1; 
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
	    if(vRetResult.size() % (iMaxRecPerPage*15) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
	 
 %>
<body onload="javascript:window.print();">
<form name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
    <td width="194%" height="25" colspan="8" align="center"  class="thinborder" ><b>:: LIST OF ITEMS CREATED  ::</b></td>
  </tr> 
  <tr>
    <td width="14%" height="25" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>CATEGORY</b></font></td>
    <td width="10%" height="25" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>ITEM CODE </b></font></td>
    <td width="14%" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">ITEM NAME </font></b></td>
    <td width="7%" height="25" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">PURCHASE UNIT </font></b></td>
    <td width="10%" height="25" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>SELLING  UNIT </b></font></td>
    <td width="9%" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>CONVERSION</b></font></td>
    <td width="9%" class="thinborderBOTTOMLEFT" align="center"><font size="1"><b>SELLING PRICE </b></font></td>
    <td width="10%" height="25" class="thinborderBOTTOMLEFT" align="center"><b><font size="1">DATE CREATED  </font></b></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=17,++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	
	<tr>
    <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
    <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"n/a")%></td>
    <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9),"n/a")%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+10);
			strTemp = CommonUtil.formatFloat(strTemp, true);
		%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=strTemp%>&nbsp;</td>
    <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
    </tr>
	<%}%>
</table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" ></DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>


</form>
 </body>
</html>
<%
dbOP.cleanUP();
%>